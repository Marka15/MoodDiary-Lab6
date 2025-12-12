import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/login_model.dart';
import '../pages/dashboard_page.dart';
import 'registration_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFD4E5D4),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
      
              child: Consumer<LoginModel>(
                builder: (context, model, _) => _LoginCard(model: model),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _LoginCard extends StatefulWidget {
  final LoginModel model;
  const _LoginCard({required this.model});

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double baseWidth = 400;
        final double scaleFactor =
            constraints.maxWidth < baseWidth ? constraints.maxWidth / baseWidth : 0.8;

      
        return Form(
          key: _formKey,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.all(32 * scaleFactor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(scaleFactor),
                SizedBox(height: 32 * scaleFactor),
                
              
                TextFormField(
                  onChanged: widget.model.setEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                      scaleFactor: scaleFactor, hintText: 'user@example.com'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Будь ласка, введіть ваш email';
                    }
                    final emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                    if (!emailRegex.hasMatch(value)) {
                      return 'Будь ласка, введіть коректний email';
                    }
                    return null; 
                  },
                ),
                SizedBox(height: 16 * scaleFactor),
                TextFormField(
                  onChanged: widget.model.setPassword,
                  obscureText: !widget.model.isPasswordVisible,
                  decoration: _inputDecoration(
                    scaleFactor: scaleFactor,
                    hintText: '••••••••',
                  ).copyWith( // Додаємо іконку окремо
                    suffixIcon: IconButton(
                      icon: Icon(
                        widget.model.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF6B8E6B),
                      ),
                      onPressed: widget.model.togglePasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Будь ласка, введіть пароль';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24 * scaleFactor),
                
                // логіка кнопки
                SizedBox(
                  width: double.infinity,
                  height: 50 * scaleFactor,
                  child: ElevatedButton(
                    onPressed: widget.model.isLoading
                        ? null
                        : () async {
                          
                            if (_formKey.currentState?.validate() ?? false) {
                              
                              final success = await widget.model.login();
                              if (success && mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const DashboardPage(),
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5FB35F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor:
                          const Color(0xFF5FB35F).withOpacity(0.6),
                    ),
                    child: widget.model.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Увійти',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                SizedBox(height: 8),
                _ErrorMessage(scaleFactor: scaleFactor),
                _ForgotPasswordButton(scaleFactor: scaleFactor),
                SizedBox(height: 16 * scaleFactor),
                Text('або',
                    style: TextStyle(
                        color: Color(0xFF9E9E9E), fontSize: 14 * scaleFactor)),
                SizedBox(height: 16 * scaleFactor),

    
              _GoogleSignInButton(
                scaleFactor: scaleFactor,
                onPressed: widget.model.isLoading
                    ? null 
                    : () async {
                        final success = await widget.model.signInWithGoogle();
                        if (success && mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const DashboardPage(),
                            ),
                          );
                        }
                      },
              ),
              SizedBox(height: 24 * scaleFactor), // <-- Додайте відступ


                _SignUpSection(scaleFactor: scaleFactor),
              ],
            ),
          ),
        );
      },
    );
  }

  

  InputDecoration _inputDecoration({
    required double scaleFactor,
    required String hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      border: _inputBorder(),
      enabledBorder: _inputBorder(),
      focusedBorder: _inputBorder(focused: true),
      errorBorder: _inputBorder(error: true),
      focusedErrorBorder: _inputBorder(focused: true, error: true),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20 * scaleFactor,
        vertical: 16 * scaleFactor,
      ),
    );
  }

  OutlineInputBorder _inputBorder({bool focused = false, bool error = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: error ? Colors.red : const Color(0xFF5FB35F),
        width: focused ? 2 : 1,
      ),
    );
  }

  Widget _buildHeader(double scaleFactor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, color: const Color(0xFF5FB35F), size: 40 * scaleFactor),
            SizedBox(width: 12 * scaleFactor),
            Text(
              'MoodDiary',
              style: TextStyle(
                fontSize: 36 * scaleFactor,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5FB35F),
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * scaleFactor),
        Text(
          'Ваш персональний щоденник емоційного стану',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14 * scaleFactor, color: const Color(0xFF6B8E6B)),
        ),
      ],
    );
  }
}
class _GoogleSignInButton extends StatelessWidget {
  final double scaleFactor;
  final VoidCallback? onPressed;

  const _GoogleSignInButton({required this.scaleFactor, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50 * scaleFactor,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          'assets/google_logo.png', 
          height: 24 * scaleFactor,
        ),
        label: Text(
          'Увійти через Google',
          style: TextStyle(
            fontSize: 16 * scaleFactor,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.7),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final double scaleFactor;
  const _ErrorMessage({required this.scaleFactor});

  @override
  Widget build(BuildContext context) {
    
    final model = Provider.of<LoginModel>(context);
    if (model.errorMessage == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        model.errorMessage!,
        style: TextStyle(color: Colors.red, fontSize: 14 * scaleFactor),
        textAlign: TextAlign.center,
      ),
    );
  }
}



class _ForgotPasswordButton extends StatelessWidget {
  final double scaleFactor;
  const _ForgotPasswordButton({required this.scaleFactor});

   @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Відновлення пароля')),
        );
      },
      icon: Icon(Icons.key, size: 18 * scaleFactor),
      label: Text(
        'Забули пароль?',
        style: TextStyle(fontSize: 14 * scaleFactor),
      ),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF6B8E6B),
      ),
    );
  }
}

class _SignUpSection extends StatelessWidget {
  final double scaleFactor;
  const _SignUpSection({required this.scaleFactor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Немає облікового запису? ',
              style: TextStyle(color: const Color(0xFF6B8E6B), fontSize: 14 * scaleFactor),
            ),
            Icon(Icons.person_add, size: 18 * scaleFactor, color: const Color(0xFF6B8E6B)),
          ],
        ),
        SizedBox(height: 8 * scaleFactor),
        TextButton(
          onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegistrationPage()),
            );
          },
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF5FB35F)),
          child: Text(
            'Зареєструватися',
            style: TextStyle(
              fontSize: 16 * scaleFactor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}