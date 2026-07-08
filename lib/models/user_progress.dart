class UserProgress {
  final String username;
  final int lessonId;
  final bool completed;
  final int score;
  final int correctCount;
  final DateTime? completedAt;

  UserProgress({
    required this.username,
    required this.lessonId,
    required this.completed,
    required this.score,
    this.correctCount = 0,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'lessonId': lessonId,
      'completed': completed ? 1 : 0,
      'score': score,
      'correctCount': correctCount,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      username: map['username'] as String,
      lessonId: map['lessonId'] as int,
      completed: (map['completed'] as int) == 1,
      score: map['score'] as int,
      correctCount: (map['correctCount'] as int?) ?? 0,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
    );
  }
}

