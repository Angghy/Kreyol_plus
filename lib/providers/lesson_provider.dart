import 'package:flutter/foundation.dart';
import '../models/lesson.dart';
import '../services/database_service.dart';

class LessonProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Lesson> _allLessons = [];
  List<Lesson> _filteredLessons = [];
  Lesson? _currentLesson;
  bool _isLoading = false;
  String? _selectedCategory;

  List<Lesson> get allLessons => _allLessons;
  List<Lesson> get filteredLessons => _filteredLessons;
  Lesson? get currentLesson => _currentLesson;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;
  List<String> get categories {
    final cats = _allLessons.map((l) => l.category).toSet().toList();
    return cats;
  }

  Future<void> loadAllLessons() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allLessons = await _databaseService.getAllLessons();
      if (_selectedCategory != null) {
        _filteredLessons = _allLessons.where((l) => l.category == _selectedCategory).toList();
      } else {
        _filteredLessons = _allLessons;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading lessons: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByCategory(String category) async {
    _selectedCategory = category;
    _isLoading = true;
    notifyListeners();

    try {
      _filteredLessons = await _databaseService.getLessonsByCategory(category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error filtering lessons: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearFilter() async {
    _selectedCategory = null;
    _filteredLessons = _allLessons;
    notifyListeners();
  }

  Future<Lesson?> getLessonById(int id) async {
    try {
      _currentLesson = await _databaseService.getLesson(id);
      notifyListeners();
      return _currentLesson;
    } catch (e) {
      print('Error getting lesson: $e');
      return null;
    }
  }

  void setCurrentLesson(Lesson lesson) {
    _currentLesson = lesson;
    notifyListeners();
  }
}

