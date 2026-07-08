import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lesson_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/lesson_card.dart';
import 'lesson_detail_view.dart';

class LessonListView extends StatefulWidget {
  const LessonListView({Key? key}) : super(key: key);

  @override
  State<LessonListView> createState() => _LessonListViewState();
}

class _LessonListViewState extends State<LessonListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LessonProvider>();
      if (provider.allLessons.isEmpty) {
        provider.loadAllLessons();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LessonProvider>(
          builder: (context, lessonProvider, _) {
            if (lessonProvider.selectedCategory != null) {
              return Text('${lessonProvider.selectedCategory}');
            }
            return const Text('Leçons');
          },
        ),
        actions: [
          Consumer<LessonProvider>(
            builder: (context, lessonProvider, _) {
              if (lessonProvider.selectedCategory != null) {
                return IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    lessonProvider.clearFilter();
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: Consumer2<LessonProvider, ProgressProvider>(
        builder: (context, lessonProvider, progressProvider, _) {
          if (lessonProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (lessonProvider.filteredLessons.isEmpty) {
            return const Center(
              child: Text('Aucune leçon trouvée'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lessonProvider.filteredLessons.length,
            itemBuilder: (context, index) {
              final lesson = lessonProvider.filteredLessons[index];
              final isCompleted = progressProvider.isLessonCompleted(lesson.id);

              return LessonCard(
                lesson: lesson,
                isCompleted: isCompleted,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LessonDetailView(
                        lessonId: lesson.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

