import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/lesson_provider.dart';
import '../providers/progress_provider.dart';
import 'lesson_list_view.dart';
import 'quiz_list_view.dart';
import 'progress_view.dart';
import 'profile_view.dart';
import 'login_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    final lessonProvider = context.read<LessonProvider>();
    final progressProvider = context.read<ProgressProvider>();

    lessonProvider.loadAllLessons();
    if (authProvider.currentUser != null) {
      progressProvider.loadUserProgress(authProvider.currentUser!.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Kreyòl+'),
            centerTitle: true,
            elevation: 0,
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          authProvider.currentUser?.username[0].toUpperCase() ??
                              'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        authProvider.currentUser?.username ?? 'Utilisateur',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Accueil'),
                  onTap: () {
                    setState(() => _currentIndex = 0);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text('Leçons'),
                  onTap: () {
                    context.read<LessonProvider>().clearFilter();
                    setState(() => _currentIndex = 1);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.quiz),
                  title: const Text('Quiz'),
                  onTap: () {
                    setState(() => _currentIndex = 2);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.trending_up),
                  title: const Text('Progression'),
                  onTap: () {
                    setState(() => _currentIndex = 3);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profil'),
                  onTap: () {
                    setState(() => _currentIndex = 4);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Déconnexion'),
                  onTap: () {
                    context.read<ProgressProvider>().clear();
                    authProvider.logout();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginView(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              HomeContent(),
              LessonListView(),
              QuizListView(),
              ProgressView(),
              ProfileView(),
            ],
          ),
        );
      },
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, LessonProvider, ProgressProvider>(
      builder: (context, authProvider, lessonProvider, progressProvider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenue ${authProvider.currentUser?.username}!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Continuez à apprendre le créole haïtien',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Leçons',
                        '${progressProvider.completedLessons}${progressProvider.totalLessons > 0 ? '/${progressProvider.totalLessons}' : ''}',
                        Icons.school,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Points',
                        '${progressProvider.totalScore}',
                        Icons.star,
                        Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Badges',
                        '${progressProvider.unlockedBadges.length}',
                        Icons.emoji_events,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Categories
                Text(
                  'Catégories de leçons',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: lessonProvider.categories.length,
                  itemBuilder: (context, index) {
                    String category = lessonProvider.categories[index];
                    return _buildCategoryCard(context, category);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category) {
    final Map<String, IconData> categoryIcons = {
      'Vocabulaire': Icons.abc,
      'Expression': Icons.lightbulb,
      'Phrase courante': Icons.chat_bubble,
      'Grammaire': Icons.book,
    };

    final Map<String, Color> categoryColors = {
      'Vocabulaire': Colors.blue,
      'Expression': Colors.purple,
      'Phrase courante': Colors.green,
      'Grammaire': Colors.orange,
    };

    return GestureDetector(
      onTap: () async {
        await context.read<LessonProvider>().filterByCategory(category);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LessonListView(),
          ),
        );
      },
      child: Card(
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                categoryColors[category]?.withOpacity(0.3) ??
                    Colors.blue.withOpacity(0.3),
                categoryColors[category]?.withOpacity(0.1) ??
                    Colors.blue.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                categoryIcons[category] ?? Icons.category,
                size: 40,
                color: categoryColors[category] ?? Colors.blue,
              ),
              const SizedBox(height: 8),
              Text(
                category,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

