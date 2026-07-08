class Question {
  final int id;
  final String type; // 'oral' or 'textuel'
  final String category;
  final int lessonId;
  final String text;
  final String? audioPath;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.id,
    required this.type,
    required this.category,
    required this.lessonId,
    required this.text,
    this.audioPath,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      type: json['type'] as String,
      category: json['category'] as String,
      lessonId: json['lessonId'] as int,
      text: json['text'] as String,
      audioPath: json['audioPath'] as String?,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'lessonId': lessonId,
      'text': text,
      'audioPath': audioPath,
      'options': options.join('|'),
      'correctIndex': correctIndex,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int,
      type: map['type'] as String,
      category: map['category'] as String,
      lessonId: map['lessonId'] as int,
      text: map['text'] as String,
      audioPath: map['audioPath'] as String?,
      options: (map['options'] as String).split('|'),
      correctIndex: map['correctIndex'] as int,
    );
  }
}

