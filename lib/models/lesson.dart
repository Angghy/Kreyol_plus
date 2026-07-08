class Lesson {
  final int id;
  final String category;
  final String title;
  final String content;
  final String audioPath;
  final int order;
  final String status; // 'completed' or 'not completed'

  Lesson({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.audioPath,
    required this.order,
    this.status = 'not completed',
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      category: json['category'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      audioPath: json['audioPath'] as String,
      order: json['order'] as int,
      status: (json['status'] as String?) ?? 'not completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'content': content,
      'audioPath': audioPath,
      'order': order,
      'status': status,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'content': content,
      'audioPath': audioPath,
      'orderNum': order,
      'status': status,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as int,
      category: map['category'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      audioPath: map['audioPath'] as String,
      order: map['orderNum'] as int,
      status: (map['status'] as String?) ?? 'not completed',
    );
  }
}

