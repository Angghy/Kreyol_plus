import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/audio_service.dart';
import '../models/question.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';

class QuizListView extends StatefulWidget {
  const QuizListView({Key? key}) : super(key: key);

  @override
  State<QuizListView> createState() => _QuizListViewState();
}

class _QuizListViewState extends State<QuizListView> {
  late Future<Map<String, List<Question>>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    final dbService = DatabaseService();
    _quizzesFuture = _loadQuizzes(dbService);
  }

  Future<Map<String, List<Question>>> _loadQuizzes(
    DatabaseService dbService,
  ) async {
    final textQuestions = await dbService.getQuestionsByType('textuel');
    final oralQuestions = await dbService.getQuestionsByType('oral');

    return {
      'textuel': textQuestions,
      'oral': oralQuestions,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: FutureBuilder<Map<String, List<Question>>>(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Aucun quiz trouvé'));
          }

          final quizzes = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Textuel Quiz
              if (quizzes['textuel']!.isNotEmpty)
                _buildQuizCard(
                  context,
                  'Quiz Textuel',
                  'Répondez à des questions basées sur le texte',
                  quizzes['textuel']!.length,
                  Colors.blue,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QuizSessionView(
                        questions: quizzes['textuel']!,
                        quizType: 'textuel',
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // Oral Quiz
              if (quizzes['oral']!.isNotEmpty)
                _buildQuizCard(
                  context,
                  'Quiz Oral',
                  'Écoutez et répondez à des questions',
                  quizzes['oral']!.length,
                  Colors.orange,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QuizSessionView(
                        questions: quizzes['oral']!,
                        quizType: 'oral',
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuizCard(
    BuildContext context,
    String title,
    String description,
    int questionCount,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$questionCount Q',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizSessionView extends StatefulWidget {
  final List<Question> questions;
  final String quizType;

  const QuizSessionView({
    Key? key,
    required this.questions,
    required this.quizType,
  }) : super(key: key);

  @override
  State<QuizSessionView> createState() => _QuizSessionViewState();
}

class _QuizSessionViewState extends State<QuizSessionView> {
  late AudioService _audioService;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswersCount = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
  }

  @override
  void dispose() {
    _audioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.quizType} (${_currentQuestionIndex + 1}/${widget.questions.length})'),
      ),
      body: _buildQuestionView(),
    );
  }

  Widget _buildQuestionView() {
    final question = widget.questions[_currentQuestionIndex];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Container(
            width: double.infinity,
            height: 4,
            color: Colors.grey.shade300,
            child: Container(
              width: ((_currentQuestionIndex + 1) / widget.questions.length) *
                  MediaQuery.of(context).size.width,
              color: Colors.green,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question text
                Text(
                  question.text,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                // Audio button for oral questions
                if (question.audioPath != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      onPressed: () {
                        _audioService.playAudio(question.audioPath!);
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Écouter'),
                    ),
                  ),
                // Options
                ...List.generate(
                  question.options.length,
                  (index) => GestureDetector(
                          onTap: _hasAnswered
                                ? null
                                : () {
                                    setState(() {
                                      _selectedAnswerIndex = index;
                                      _hasAnswered = true;
                                      if (index == question.correctIndex) {
                                        _score += _calculatePoints(question);
                                        _correctAnswersCount++;
                                      }
                                    });
                                  },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: _getOptionBackgroundColor(index, question),
                        border: Border.all(
                          color: _getOptionBorderColor(index, question),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: TextStyle(
                                fontSize: 16,
                                color: _getOptionTextColor(index, question),
                                fontWeight: _selectedAnswerIndex == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (_hasAnswered && _selectedAnswerIndex == index)
                            Icon(
                              index == question.correctIndex
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: index == question.correctIndex
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          if (_hasAnswered &&
                              _selectedAnswerIndex != index &&
                              index == question.correctIndex)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Next button
                if (_hasAnswered)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentQuestionIndex < widget.questions.length - 1) {
                          setState(() {
                            _currentQuestionIndex++;
                            _selectedAnswerIndex = null;
                            _hasAnswered = false;
                          });
                        } else {
                          _showResultsDialog();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        _currentQuestionIndex < widget.questions.length - 1
                            ? 'Suivant'
                            : 'Terminer',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getOptionBackgroundColor(int index, Question question) {
    if (!_hasAnswered) {
      return Colors.white;
    }
    if (index == _selectedAnswerIndex) {
      return index == question.correctIndex
          ? Colors.green.shade100
          : Colors.red.shade100;
    }
    if (index == question.correctIndex) {
      return Colors.green.shade100;
    }
    return Colors.white;
  }

  Color _getOptionBorderColor(int index, Question question) {
    if (!_hasAnswered) {
      return Colors.grey.shade300;
    }
    if (index == _selectedAnswerIndex) {
      return index == question.correctIndex ? Colors.green : Colors.red;
    }
    if (index == question.correctIndex) {
      return Colors.green;
    }
    return Colors.grey.shade300;
  }

  Color _getOptionTextColor(int index, Question question) {
    if (!_hasAnswered) {
      return Colors.black;
    }
    if (index == _selectedAnswerIndex) {
      return index == question.correctIndex
          ? Colors.green.shade900
          : Colors.red.shade900;
    }
    if (index == question.correctIndex) {
      return Colors.green.shade900;
    }
    return Colors.black;
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quiz terminé!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              'Questions réussies: $_correctAnswersCount / ${widget.questions.length}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Points obtenus:',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '$_score points',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Save progress
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
              
              if (authProvider.currentUser != null) {
                // If it's a lesson quiz, we might have a lessonId. 
                // For general quizzes, we might need a dummy lessonId or a separate table.
                // Assuming lessonId 0 for general quizzes if not specified.
                int lessonId = widget.questions.isNotEmpty ? widget.questions.first.lessonId : 0;
                
                await progressProvider.completeLesson(
                  authProvider.currentUser!.username,
                  lessonId,
                  _score,
                  correctCount: _correctAnswersCount,
                );
              }
              
              if (!mounted) return;
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  int _calculatePoints(Question question) {
    bool isOral = widget.quizType == 'oral';
    String category = question.category;

    if (!isOral) {
      // Textual
      if (category == 'Vocabulaire' || category == 'Grammaire') {
        return 1;
      } else {
        // Expression or Phrase courante
        return 5;
      }
    } else {
      // Oral
      if (category == 'Vocabulaire' || category == 'Grammaire') {
        return 5;
      } else {
        // Expression or Phrase courante
        return 10;
      }
    }
  }
}


