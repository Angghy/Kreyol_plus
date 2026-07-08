class Badge {
  final int id;
  final String title;
  final String description;
  final String iconPath;
  final int unlockCondition; // number of lessons to complete for this badge

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.unlockCondition,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'unlockCondition': unlockCondition,
    };
  }

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      iconPath: map['iconPath'] as String,
      unlockCondition: map['unlockCondition'] as int,
    );
  }
}

class UserBadge {
  final String username;
  final int badgeId;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  UserBadge({
    required this.username,
    required this.badgeId,
    required this.isUnlocked,
    this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'badgeId': badgeId,
      'isUnlocked': isUnlocked ? 1 : 0,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory UserBadge.fromMap(Map<String, dynamic> map) {
    return UserBadge(
      username: map['username'] as String,
      badgeId: map['badgeId'] as int,
      isUnlocked: (map['isUnlocked'] as int) == 1,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'] as String)
          : null,
    );
  }
}

