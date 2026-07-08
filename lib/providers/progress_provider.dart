import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../models/badge.dart';
import '../services/database_service.dart';

class ProgressProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<UserProgress> _userProgress = [];
  List<Badge> _allBadges = [];
  List<Badge> _unlockedBadges = [];
  int _totalScore = 0;
  int _completedLessons = 0;
  int _totalLessons = 0;
  int _totalQuestions = 0;
  int _completedQuestions = 0;
  bool _isLoading = false;

  List<UserProgress> get userProgress => _userProgress;
  List<Badge> get allBadges => _allBadges;
  List<Badge> get unlockedBadges => _unlockedBadges;
  int get totalScore => _totalScore;
  int get completedLessons => _completedLessons;
  int get totalLessons => _totalLessons;
  int get totalQuestions => _totalQuestions;
  int get completedQuestions => _completedQuestions;
  bool get isLoading => _isLoading;
  
  double get progressPercentage {
    if (_totalLessons == 0) return 0;
    double percentage = (_completedLessons / _totalLessons) * 100;
    return percentage > 100 ? 100 : percentage;
  }

  Future<void> loadUserProgress(String username) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userProgress = await _databaseService.getUserProgress(username);
      _totalScore = await _databaseService.getTotalScore(username);
      _completedLessons = await _databaseService.getCompletedLessonsCount(username);
      _totalLessons = await _databaseService.getTotalLessonsCount();
      _totalQuestions = await _databaseService.getTotalQuestionsCount();
      _completedQuestions = await _databaseService.getCompletedQuestionsCount(username);
      _allBadges = await _databaseService.getAllBadges();

      // Load unlocked badges
      _unlockedBadges = [];
      for (var badge in _allBadges) {
        bool isUnlocked = await _databaseService.isBadgeUnlocked(username, badge.id);
        if (isUnlocked) {
          _unlockedBadges.add(badge);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading progress: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeLesson(String username, int lessonId, int score, {int correctCount = 0}) async {
    try {
      UserProgress progress = UserProgress(
        username: username,
        lessonId: lessonId,
        completed: true,
        score: score,
        correctCount: correctCount,
        completedAt: DateTime.now(),
      );
      await _databaseService.saveProgress(progress);

      // Check for badge unlocks FIRST
      // We need to reload the count before checking
      _completedLessons = await _databaseService.getCompletedLessonsCount(username);
      await _checkAndUnlockBadges(username);

      // THEN reload everything to update UI
      await loadUserProgress(username);
    } catch (e) {
      print('Error completing lesson: $e');
    }
  }

  Future<void> _checkAndUnlockBadges(String username) async {
    for (var badge in _allBadges) {
      bool isAlreadyUnlocked = await _databaseService.isBadgeUnlocked(username, badge.id);
      if (!isAlreadyUnlocked && _completedLessons >= badge.unlockCondition) {
        await _databaseService.unlockBadge(username, badge.id);
      }
    }
  }

  UserProgress? getProgressForLesson(int lessonId) {
    try {
      return _userProgress.firstWhere((p) => p.lessonId == lessonId);
    } catch (e) {
      return null;
    }
  }

  bool isLessonCompleted(int lessonId) {
    UserProgress? progress = getProgressForLesson(lessonId);
    return progress?.completed ?? false;
  }
}

