import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  User? _currentUser;
  String? _error;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> signup(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if user already exists
      User? existingUser = await _databaseService.getUser(username);
      if (existingUser != null) {
        _error = 'Cet utilisateur existe déjà';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate password
      if (password.length < 6) {
        _error = 'Le mot de passe doit contenir au moins 6 caractères';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create user
      String passwordHash = _authService.hashPassword(password);
      User newUser = User(
        username: username,
        passwordHash: passwordHash,
      );
      await _databaseService.createUser(newUser);
      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'inscription: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      User? user = await _databaseService.getUser(username);
      if (user == null) {
        _error = 'Utilisateur non trouvé';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!_authService.verifyPassword(password, user.passwordHash)) {
        _error = 'Mot de passe incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la connexion: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (newPassword.length < 6) {
        _error = 'Le mot de passe doit contenir au moins 6 caractères';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      String passwordHash = _authService.hashPassword(newPassword);
      await _databaseService.updatePassword(_currentUser!.username, passwordHash);
      
      // Update local user object
      _currentUser = User(
        username: _currentUser!.username,
        passwordHash: passwordHash,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors du changement de mot de passe: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

