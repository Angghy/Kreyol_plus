import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  // Simple password hashing (in production, use proper bcrypt)
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }
}

