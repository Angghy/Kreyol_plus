import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/lesson.dart';
import '../models/question.dart';
import '../models/user.dart';
import '../models/user_progress.dart';
import '../models/badge.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'kreyol_plus.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    // Ensure initial data is present in case the database existed but was empty
    try {
      final List<Map<String, dynamic>> lessonsCount = await _database!.rawQuery('SELECT COUNT(*) as count FROM lessons');
      final List<Map<String, dynamic>> questionsCount = await _database!.rawQuery('SELECT COUNT(*) as count FROM questions');
      
      if ((lessonsCount[0]['count'] as int) == 0 || (questionsCount[0]['count'] as int) == 0) {
        await _loadInitialData(_database!);
      }
    } catch (e) {
      // If table doesn't exist yet (race) ignore; onCreate should handle it
      print('Error checking initial data: $e');
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        // Ensure column exists when opening existing DB
        await _ensureLessonStatusColumn(db);
        await _ensureUserProgressCorrectCountColumn(db);
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        username TEXT PRIMARY KEY,
        passwordHash TEXT NOT NULL
      )
    ''');

    // Create lessons table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS lessons (
        id INTEGER PRIMARY KEY,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        audioPath TEXT NOT NULL,
        orderNum INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'not completed'
      )
    ''');

    // Create questions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS questions (
        id INTEGER PRIMARY KEY,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        lessonId INTEGER NOT NULL,
        text TEXT NOT NULL,
        audioPath TEXT,
        options TEXT NOT NULL,
        correctIndex INTEGER NOT NULL,
        FOREIGN KEY(lessonId) REFERENCES lessons(id)
      )
    ''');

    // Create user_progress table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_progress (
        username TEXT NOT NULL,
        lessonId INTEGER NOT NULL,
        completed INTEGER NOT NULL,
        score INTEGER NOT NULL DEFAULT 0,
        correctCount INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        PRIMARY KEY(username, lessonId),
        FOREIGN KEY(username) REFERENCES users(username),
        FOREIGN KEY(lessonId) REFERENCES lessons(id)
      )
    ''');

    // Create badges table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS badges (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        iconPath TEXT NOT NULL,
        unlockCondition INTEGER NOT NULL
      )
    ''');

    // Create user_badges table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_badges (
        username TEXT NOT NULL,
        badgeId INTEGER NOT NULL,
        isUnlocked INTEGER NOT NULL,
        unlockedAt TEXT,
        PRIMARY KEY(username, badgeId),
        FOREIGN KEY(username) REFERENCES users(username),
        FOREIGN KEY(badgeId) REFERENCES badges(id)
      )
    ''');

    // Load initial data
    await _loadInitialData(db);
  }

  // Ensure user_progress table has 'correctCount' column
  Future<void> _ensureUserProgressCorrectCountColumn(Database db) async {
    final List<Map<String, dynamic>> info =
        await db.rawQuery("PRAGMA table_info('user_progress')");
    final hasCorrectCount = info.any((col) => col['name'] == 'correctCount');
    if (!hasCorrectCount) {
      await db.execute("ALTER TABLE user_progress ADD COLUMN correctCount INTEGER NOT NULL DEFAULT 0");
    }
  }

  // Ensure lessons table has 'status' column for older DBs
  Future<void> _ensureLessonStatusColumn(Database db) async {
    final List<Map<String, dynamic>> info =
        await db.rawQuery("PRAGMA table_info('lessons')");
    final hasStatus = info.any((col) => col['name'] == 'status');
    if (!hasStatus) {
      await db.execute("ALTER TABLE lessons ADD COLUMN status TEXT NOT NULL DEFAULT 'not completed'");
    }
  }

  Future<void> _loadInitialData(Database db) async {
    // Load lessons from JSON
    String lessonsJson = await rootBundle.loadString('assets/data/lessons.json');
    List<dynamic> lessonsData = jsonDecode(lessonsJson);
    for (var lessonData in lessonsData) {
      String audioPath = (lessonData['audioPath'] as String?) ?? '';
      // Normalize audio path: JSON uses "audio/..." but assets are under assets/audios/...
      if (audioPath.startsWith('audio/')) {
        audioPath = 'assets/audios/' + audioPath.substring('audio/'.length);
      }
      // If JSON already has 'assets/audios' keep as is; if it has 'audios/' prefix, normalize
      if (audioPath.startsWith('audios/')) {
        audioPath = 'assets/' + audioPath;
      }
      await db.insert('lessons', {
        'id': lessonData['id'],
        'category': lessonData['category'],
        'title': lessonData['title'],
        'content': lessonData['content'],
        'audioPath': audioPath,
        'orderNum': lessonData['order'],
        'status': (lessonData['status'] as String?) ?? 'not completed',
      });
    }

    // Load text questions from JSON
    String quizTextJson = await rootBundle.loadString('assets/data/quiz-textuel.json');
    List<dynamic> quizTextData = jsonDecode(quizTextJson);
    for (var questionData in quizTextData) {
      String? qAudio = questionData['audioPath'] as String?;
      if (qAudio != null) {
        if (qAudio.startsWith('audio/')) {
          qAudio = 'assets/audios/' + qAudio.substring('audio/'.length);
        } else if (qAudio.startsWith('audios/')) {
          qAudio = 'assets/' + qAudio;
        }
      }
      await db.insert('questions', {
        'id': questionData['id'],
        'type': questionData['type'],
        'category': questionData['category'],
        'lessonId': questionData['lessonId'],
        'text': questionData['text'],
        'audioPath': qAudio,
        'options': jsonEncode(questionData['options']),
        'correctIndex': questionData['correctIndex'],
      });
    }

    // Load oral questions from JSON
    String quizOralJson = await rootBundle.loadString('assets/data/quiz-oral.json');
    List<dynamic> quizOralData = jsonDecode(quizOralJson);
    for (var questionData in quizOralData) {
      String? qAudio = questionData['audioPath'] as String?;
      if (qAudio != null) {
        if (qAudio.startsWith('audio/')) {
          qAudio = 'assets/audios/' + qAudio.substring('audio/'.length);
        } else if (qAudio.startsWith('audios/')) {
          qAudio = 'assets/' + qAudio;
        }
      }
      await db.insert('questions', {
        'id': questionData['id'],
        'type': questionData['type'],
        'category': questionData['category'],
        'lessonId': questionData['lessonId'],
        'text': questionData['text'],
        'audioPath': qAudio,
        'options': jsonEncode(questionData['options']),
        'correctIndex': questionData['correctIndex'],
      });
    }

    // Create default badges
    List<Badge> badges = [
      Badge(
        id: 1,
        title: 'Première leçon',
        description: 'Complétez votre première leçon',
        iconPath: 'assets/badges/badge_premiere_lecon.jpg',
        unlockCondition: 1,
      ),
      Badge(
        id: 2,
        title: 'Persévérant',
        description: 'Complétez 5 leçons',
        iconPath: 'assets/badges/badge_perseverant.jpg',
        unlockCondition: 5,
      ),
      Badge(
        id: 3,
        title: 'Constant',
        description: 'Complétez 10 leçons',
        iconPath: 'assets/badges/badge_constant.jpg',
        unlockCondition: 10,
      ),
      Badge(
        id: 4,
        title: 'Maître de kreyòl',
        description: 'Complétez toutes les leçons',
        iconPath: 'assets/badges/badge_maitre_de_kreyol.jpg',
        unlockCondition: 40,
      ),
    ];

    for (var badge in badges) {
      await db.insert('badges', badge.toMap());
    }
  }

  // User operations
  Future<void> createUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String username) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // Lesson operations
  Future<List<Lesson>> getAllLessons() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('lessons');
    return List.generate(maps.length, (i) => Lesson.fromMap(maps[i]));
  }

  Future<List<Lesson>> getLessonsByCategory(String category) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'orderNum',
    );
    return List.generate(maps.length, (i) => Lesson.fromMap(maps[i]));
  }

  Future<Lesson?> getLesson(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Lesson.fromMap(result.first);
  }

  // Question operations
  Future<List<Question>> getQuestionsByLesson(int lessonId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'lessonId = ?',
      whereArgs: [lessonId],
    );
    return List.generate(maps.length, (i) {
      var map = maps[i];
      return Question(
        id: map['id'] as int,
        type: map['type'] as String,
        category: map['category'] as String,
        lessonId: map['lessonId'] as int,
        text: map['text'] as String,
        audioPath: map['audioPath'] as String?,
        options: List<String>.from(jsonDecode(map['options'])),
        correctIndex: map['correctIndex'] as int,
      );
    });
  }

  Future<List<Question>> getQuestionsByType(String type) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'type = ?',
      whereArgs: [type],
    );
    return List.generate(maps.length, (i) {
      var map = maps[i];
      return Question(
        id: map['id'] as int,
        type: map['type'] as String,
        category: map['category'] as String,
        lessonId: map['lessonId'] as int,
        text: map['text'] as String,
        audioPath: map['audioPath'] as String?,
        options: List<String>.from(jsonDecode(map['options'])),
        correctIndex: map['correctIndex'] as int,
      );
    });
  }

  // Progress operations
  Future<void> saveProgress(UserProgress progress) async {
    final db = await database;
    await db.insert(
      'user_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProgress?> getProgress(String username, int lessonId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'user_progress',
      where: 'username = ? AND lessonId = ?',
      whereArgs: [username, lessonId],
    );
    if (result.isEmpty) return null;
    return UserProgress.fromMap(result.first);
  }

  Future<List<UserProgress>> getUserProgress(String username) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      where: 'username = ?',
      whereArgs: [username],
    );
    return List.generate(maps.length, (i) => UserProgress.fromMap(maps[i]));
  }

  Future<int> getCompletedLessonsCount(String username) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_progress WHERE username = ? AND completed = 1',
      [username],
    );
    return result.isEmpty ? 0 : (result[0]['count'] as int? ?? 0);
  }

  Future<int> getTotalScore(String username) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(score) as totalScore FROM user_progress WHERE username = ?',
      [username],
    );
    return result.isEmpty || result[0]['totalScore'] == null
        ? 0
        : (result[0]['totalScore'] as int? ?? 0);
  }

  Future<int> getCompletedQuestionsCount(String username) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(correctCount) as totalCorrect FROM user_progress WHERE username = ?',
      [username],
    );
    return result.isEmpty || result[0]['totalCorrect'] == null
        ? 0
        : (result[0]['totalCorrect'] as int? ?? 0);
  }

  // Badge operations
  Future<List<Badge>> getAllBadges() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('badges');
    return List.generate(maps.length, (i) => Badge.fromMap(maps[i]));
  }

  Future<void> unlockBadge(String username, int badgeId) async {
    final db = await database;
    await db.insert(
      'user_badges',
      {
        'username': username,
        'badgeId': badgeId,
        'isUnlocked': 1,
        'unlockedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isBadgeUnlocked(String username, int badgeId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'user_badges',
      where: 'username = ? AND badgeId = ? AND isUnlocked = 1',
      whereArgs: [username, badgeId],
    );
    return result.isNotEmpty;
  }

  Future<List<Badge>> getUnlockedBadges(String username) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT b.* FROM badges b
      INNER JOIN user_badges ub ON b.id = ub.badgeId
      WHERE ub.username = ? AND ub.isUnlocked = 1
      ''',
      [username],
    );
    return List.generate(maps.length, (i) => Badge.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // Update lesson status
  Future<void> updateLessonStatus(int lessonId, String status) async {
    final db = await database;
    await db.update(
      'lessons',
      {'status': status},
      where: 'id = ?',
      whereArgs: [lessonId],
    );
  }

  // Update password
  Future<void> updatePassword(String username, String newPasswordHash) async {
    final db = await database;
    await db.update(
      'users',
      {'passwordHash': newPasswordHash},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<int> getTotalLessonsCount() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery('SELECT COUNT(*) as count FROM lessons');
    return result.isEmpty ? 0 : (result[0]['count'] as int? ?? 0);
  }

  Future<int> getTotalQuestionsCount() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery('SELECT COUNT(*) as count FROM questions');
    return result.isEmpty ? 0 : (result[0]['count'] as int? ?? 0);
  }
}



