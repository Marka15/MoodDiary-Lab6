import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class LoginModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  String _email = '';
  String _password = '';
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  String get email => _email;
  String get password => _password;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // --- ВХІД ЧЕРЕЗ EMAIL ---
  Future<bool> login() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      if (userCredential.user != null) {
        // Встановлення user properties
        await _trackUserLoginAttributes(userCredential.user!, 'email_password');
        
        // Для успішного входу через пароль
        await _analytics.logEvent(
          name: 'login_successful',
          parameters: {
            'method': 'email_password',
            'email_domain': _email.split('@').last,
          },
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;

    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthExceptionToMessage(e.code);
      
      // Невдалий вхід через пароль
      await _analytics.logEvent(
        name: 'login_failed',
        parameters: {
          'method': 'email_password',
          'error_code': e.code,
        },
      );
      
      _isLoading = false;
      notifyListeners();
      return false;

    } catch (e) {
      _errorMessage = 'Виникла невідома помилка. Спробуйте пізніше.';
      
      await _analytics.logEvent(
        name: 'login_failed',
        parameters: {
          'method': 'email_password',
          'error_code': 'unknown',
        },
      );
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Вхід через Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Користувач скасував вхід
        await _analytics.logEvent(
          name: 'login_cancelled',
          parameters: {'method': 'google'},
        );
        
        _isLoading = false;
        notifyListeners();
        return false; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _trackUserLoginAttributes(userCredential.user!, 'google');
        
        //  Успішний  вхід через Google
        await _analytics.logEvent(
          name: 'login_successful',
          parameters: {
            'method': 'google',
            'email_domain': userCredential.user!.email?.split('@').last ?? 'unknown',
          },
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;

    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthExceptionToMessage(e.code);
      
      await _analytics.logEvent(
        name: 'login_failed',
        parameters: {
          'method': 'google',
          'error_code': e.code,
        },
      );
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Помилка входу через Google. Спробуйте пізніше.';
      
      await _analytics.logEvent(
        name: 'login_failed',
        parameters: {
          'method': 'google',
          'error_code': 'unknown',
        },
      );
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _trackUserLoginAttributes(User user, String loginMethod) async {
    await _analytics.setUserId(id: user.uid);

    // Встановлення методу входу
    await _analytics.setUserProperty(name: 'login_method', value: loginMethod);

    String fakeGender = (user.email != null && user.email!.length > 15) ? 'female' : 'male';
    await _analytics.setUserProperty(name: 'gender', value: fakeGender);

    String accountType = (user.email != null && user.email!.contains('@lpnu.ua')) 
        ? 'student' 
        : 'guest';
    await _analytics.setUserProperty(name: 'account_type', value: accountType);
    
    String domain = user.email?.split('@').last ?? 'unknown';
    await _analytics.setUserProperty(name: 'email_domain', value: domain);
    
    // Стандартна подія Firebase
    await _analytics.logLogin(loginMethod: loginMethod);
    
    print('Analytics set: Method=$loginMethod, Gender=$fakeGender, Type=$accountType, Domain=$domain');
  }

  String _mapFirebaseAuthExceptionToMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'auth/user-not-found':
        return 'Користувача з таким email не знайдено.';
      case 'wrong-password':
      case 'auth/wrong-password':
        return 'Неправильний пароль.';
      case 'invalid-email':
      case 'auth/invalid-email':
        return 'Некоректний формат email.';
      case 'network-request-failed':
        return 'Помилка мережі. Перевірте ваше інтернет-з\'єднання.';
      case 'credential-already-in-use':
        return 'Ці дані вже використовуються іншим акаунтом.';
      default:
        return 'Помилка автентифікації: $code';
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
    
  void reset() {
    _email = '';
    _password = '';
    _isPasswordVisible = false;
    _isLoading = false;
    _errorMessage = null;
  }
}