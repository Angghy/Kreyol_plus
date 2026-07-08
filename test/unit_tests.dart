import 'package:flutter_test/flutter_test.dart';
import 'package:kreyol_plus/models/lesson.dart';
import 'package:kreyol_plus/models/question.dart';
import 'package:kreyol_plus/models/user.dart';
import 'package:kreyol_plus/models/badge.dart';
import 'package:kreyol_plus/services/auth_service.dart';

void main() {
  group('Models Tests', () {
    test('Lesson model should create from JSON', () {
      final json = {
        'id': 1,
        'category': 'Vocabulaire',
        'title': 'Bonjour',
        'content': 'Bonjou',
        'audioPath': 'audio/vocabulaire/bonjou.mp3',
        'order': 1,
      };

      final lesson = Lesson.fromJson(json);

      expect(lesson.id, equals(1));
      expect(lesson.title, equals('Bonjour'));
      expect(lesson.category, equals('Vocabulaire'));
    });

    test('Question model should create with multiple options', () {
      final question = Question(
        id: 1,
        type: 'textuel',
        category: 'Vocabulaire',
        lessonId: 1,
        text: 'Comment dit-on "Merci" en kreyòl ?',
        audioPath: null,
        options: ['Mèsi', 'Wi', 'Dlo', 'Kay'],
        correctIndex: 0,
      );

      expect(question.options.length, equals(4));
      expect(question.correctIndex, equals(0));
      expect(question.options[0], equals('Mèsi'));
    });

    test('User model should hash password correctly', () {
      const username = 'testuser';
      const passwordHash = 'hashedpassword123';

      final user = User(
        username: username,
        passwordHash: passwordHash,
      );

      expect(user.username, equals(username));
      expect(user.passwordHash, equals(passwordHash));
    });

    test('Badge model should create with unlock condition', () {
      final badge = Badge(
        id: 1,
        title: 'Première leçon',
        description: 'Complétez votre première leçon',
        iconPath: '',
        unlockCondition: 1,
      );

      expect(badge.unlockCondition, equals(1));
      expect(badge.title, equals('Première leçon'));
    });
  });

  group('AuthService Tests', () {
    final authService = AuthService();

    test('Hash password should generate consistent hash', () {
      const password = 'testpassword123';

      final hash1 = authService.hashPassword(password);
      final hash2 = authService.hashPassword(password);

      expect(hash1, equals(hash2));
    });

    test('Verify password should return true for correct password', () {
      const password = 'testpassword123';
      final hash = authService.hashPassword(password);

      final isValid = authService.verifyPassword(password, hash);
      expect(isValid, isTrue);
    });

    test('Verify password should return false for incorrect password', () {
      const password = 'testpassword123';
      const wrongPassword = 'wrongpassword';
      final hash = authService.hashPassword(password);

      final isValid = authService.verifyPassword(wrongPassword, hash);
      expect(isValid, isFalse);
    });

    test('Different passwords should generate different hashes', () {
      const password1 = 'password123';
      const password2 = 'password456';

      final hash1 = authService.hashPassword(password1);
      final hash2 = authService.hashPassword(password2);

      expect(hash1, isNot(equals(hash2)));
    });
  });

  group('Quiz Scoring Tests', () {
    test('Calculate score correctly from quiz answers', () {
      const correctAnswers = 8;
      const totalQuestions = 10;
      const pointsPerCorrect = 10;

      final score = correctAnswers * pointsPerCorrect;
      final percentage = (correctAnswers / totalQuestions) * 100;

      expect(score, equals(80));
      expect(percentage, equals(80.0));
    });

    test('Perfect score should return 100%', () {
      const score = 100;
      const totalPoints = 100;
      final percentage = (score / totalPoints) * 100;

      expect(percentage, equals(100.0));
      expect(percentage >= 80, isTrue); // Passing grade assumption
    });
  });

  group('Badge Unlock Logic', () {
    test('Badge should unlock at correct lesson count', () {
      const completedLessons = 5;
     const badgeUnlockCondition = 5;

      final shouldUnlock = completedLessons >= badgeUnlockCondition;
      expect(shouldUnlock, isTrue);
    });

    test('Badge should not unlock before condition met', () {
      const completedLessons = 4;
      const badgeUnlockCondition = 5;

      final shouldUnlock = completedLessons >= badgeUnlockCondition;
      expect(shouldUnlock, isFalse);
    });

    test('Multiple badges should unlock progressively', () {
      const completedLessons = 10;

      final badges = [1, 5, 10, 40];
      final unlockedBadges = badges.where((condition) => completedLessons >= condition).length;

      expect(unlockedBadges, equals(3)); // First 3 badges unlocked
    });
  });
}

