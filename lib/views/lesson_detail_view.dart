import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lesson_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';
import '../services/audio_service.dart';
import '../services/database_service.dart';

class LessonDetailView extends StatefulWidget {
  final int lessonId;

  const LessonDetailView({
    Key? key,
    required this.lessonId,
  }) : super(key: key);

  @override
  State<LessonDetailView> createState() => _LessonDetailViewState();
}

class _LessonDetailViewState extends State<LessonDetailView> {
  late AudioService _audioService;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().getLessonById(widget.lessonId);
    });
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
        title: const Text('Leçon'),
      ),
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, _) {
          if (lessonProvider.currentLesson == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final lesson = lessonProvider.currentLesson!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with audio button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade400],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          lesson.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Audio button
                      FloatingActionButton.extended(
                        onPressed: () {
                          _audioService.playAudio(lesson.audioPath);
                        },
                        label: const Text('Écouter'),
                        icon: const Icon(Icons.play_arrow),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contenu',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SelectableText(
                          lesson.content,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 24),
                       // Complete button: mark lesson as completed
                       SizedBox(
                         width: double.infinity,
                         height: 48,
                         child: ElevatedButton(
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.green,
                           ),
                           onPressed: () async {
                             final dbService = DatabaseService();
                             final authProvider = context.read<AuthProvider>();
                             final progressProvider = context.read<ProgressProvider>();
                             
                             await dbService.updateLessonStatus(widget.lessonId, 'completed');
                             
                             if (authProvider.currentUser != null) {
                               // Scoring for manual completion: let's give 5 points by default
                               await progressProvider.completeLesson(
                                 authProvider.currentUser!.username,
                                 widget.lessonId,
                                 5,
                               );
                             }
                             
                             if (!mounted) return;
                             
                             // refresh current lesson in provider
                             await context.read<LessonProvider>().getLessonById(widget.lessonId);
                             // also reload all lessons so lists reflect status
                             if (!mounted) return;
                             await context.read<LessonProvider>().loadAllLessons();
                           },
                           child: const Text(
                             'Compléter',
                             style: TextStyle(
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
        },
      ),
    );
  }
}



