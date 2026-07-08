import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/question.dart';
import 'quiz_list_view.dart';

class QuizDetailView extends StatefulWidget {
  final int lessonId;

  const QuizDetailView({
    Key? key,
    required this.lessonId,
  }) : super(key: key);

  @override
  State<QuizDetailView> createState() => _QuizDetailViewState();
}

class _QuizDetailViewState extends State<QuizDetailView> {
  late Future<List<Question>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    final dbService = DatabaseService();
    _questionsFuture = dbService.getQuestionsByLesson(widget.lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aucun quiz disponible pour cette leçon'),
            );
          }

          final questions = snapshot.data!;

          return QuizSessionView(
            questions: questions,
            quizType: 'leçon',
          );
        },
      ),
    );
  }
}


