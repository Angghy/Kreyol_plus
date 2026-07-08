class User {
  final String username;
  final String passwordHash;

  User({
    required this.username,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'passwordHash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] as String,
      passwordHash: map['passwordHash'] as String,
    );
  }
}

