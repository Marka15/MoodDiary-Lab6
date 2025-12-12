import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  String _name = '';
  String _email = '';
  String _password = '';


  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Геттери
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  // Сеттери
  void setName(String value) {
    _name = value.trim();
    _errorMessage = null; 
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value.trim();
    _errorMessage = null;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value.trim();
    _errorMessage = null;
    notifyListeners();
  }


  // Перемикачі видимості
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  // Метод register() (без змін)
  Future<bool> register() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(_name);
      }

      _isLoading = false;
      notifyListeners();
      return true;

    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthExceptionToMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;

    } catch (e) {
      _errorMessage = 'Виникла невідома помилка. Спробуйте пізніше.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  String _mapFirebaseAuthExceptionToMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Некоректний формат email.';
      case 'email-already-in-use':
        return 'Цей email вже зареєстровано.';
      case 'weak-password':
        return 'Пароль занадто слабкий (має бути мінімум 6 символів).';
      case 'network-request-failed':
        return 'Помилка мережі. Перевірте ваше інтернет-з\'єднання.';
      default:
        return 'Помилка реєстрації: $code';
    }
  }
}