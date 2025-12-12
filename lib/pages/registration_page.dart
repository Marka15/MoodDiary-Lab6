import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/registration_model.dart';


class RegistrationPage extends StatelessWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistrationModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFD4E5D4),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            // Використовуємо Consumer, щоб передати модель у наш StatefulWidget
            child: Consumer<RegistrationModel>(
              builder: (context, model, _) => _RegistrationCard(model: model),
            ),
          ),
        ),
      ),
    );
  }
}


class _RegistrationCard extends StatefulWidget {
  final RegistrationModel model;
  const _RegistrationCard({required this.model});

  @override
  State<_RegistrationCard> createState() => _RegistrationCardState();
}

class _RegistrationCardState extends State<_RegistrationCard> {

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

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
            constraints: const BoxConstraints(maxWidth: baseWidth),
            padding: EdgeInsets.all(30 * scaleFactor),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(scaleFactor),
                SizedBox(height: 8 * scaleFactor),
                Text(
                  'Створення нового облікового запису',
                  style: TextStyle(fontSize: 15 * scaleFactor, color: const Color(0xFF6B8E6B)),
                ),
                SizedBox(height: 24 * scaleFactor),

              
                TextFormField(
                  decoration: _inputDecoration(
                    scaleFactor: scaleFactor,
                    hintText: "Ваше ім'я",
                    prefixIcon: Icons.person_outline,
                  ),
                  onChanged: widget.model.setName,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Поле імені не може бути порожнім";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16 * scaleFactor),
                TextFormField(
                  decoration: _inputDecoration(
                    scaleFactor: scaleFactor,
                    hintText: 'Email',
                    prefixIcon: Icons.email_outlined,
                  ),
                  onChanged: widget.model.setEmail,
                  keyboardType: TextInputType.emailAddress,
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
                  controller: _passwordController,
                  decoration: _inputDecoration(
                    scaleFactor: scaleFactor,
                    hintText: 'Пароль',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        widget.model.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF6B8E6B),
                        size: 22 * scaleFactor,
                      ),
                      onPressed: widget.model.togglePasswordVisibility,
                    ),
                  ),
                  obscureText: !widget.model.isPasswordVisible,
                  onChanged: widget.model.setPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Будь ласка, введіть пароль';
                    }
                    if (value.length < 6) {
                      return 'Пароль має бути не менше 6 символів';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16 * scaleFactor),
                TextFormField(
                  decoration: _inputDecoration(
                    scaleFactor: scaleFactor,
                    hintText: 'Підтвердіть пароль',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        widget.model.isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF6B8E6B),
                        size: 22 * scaleFactor,
                      ),
                      onPressed: widget.model.toggleConfirmPasswordVisibility,
                    ),
                  ),
                  obscureText: !widget.model.isConfirmPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Будь ласка, підтвердіть пароль';
                    }
                    if (value != _passwordController.text) {
                      return 'Паролі не співпадають';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16 * scaleFactor),

                if (widget.model.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0 * scaleFactor),
                    child: Text(
                      widget.model.errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 13 * scaleFactor),
                      textAlign: TextAlign.center,
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 48 * scaleFactor,
                  child: ElevatedButton(
                    // 5. Оновлюємо логіку кнопки
                    onPressed: widget.model.isLoading
                        ? null
                        : () async {
                            // Спочатку перевіряємо валідність форми
                            if (_formKey.currentState?.validate() ?? false) {
                              // Якщо валідація пройшла, викликаємо метод реєстрації
                              final success = await widget.model.register();
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Акаунт успішно створено!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.of(context).pop();
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5FB35F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor:
                          const Color(0xFF5FB35F).withOpacity(0.6),
                    ),
                    child: widget.model.isLoading
                        ? SizedBox(
                            height: 22 * scaleFactor,
                            width: 22 * scaleFactor,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            'Зареєструватися',
                            style: TextStyle(
                                fontSize: 15 * scaleFactor,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                SizedBox(height: 16 * scaleFactor),

                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0 * scaleFactor),
                      child: Text('або',
                          style: TextStyle(
                              color: const Color(0xFF9E9E9E),
                              fontSize: 13 * scaleFactor)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 8 * scaleFactor),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Вже є акаунт? Увійти',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5FB35F),
                      fontSize: 14 * scaleFactor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(double scaleFactor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.eco, color: const Color(0xFF5FB35F), size: 32 * scaleFactor),
        SizedBox(width: 10 * scaleFactor),
        Text(
          'MoodDiary',
          style: TextStyle(
            fontSize: 30 * scaleFactor,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5FB35F),
          ),
        ),
      ],
    );
  }

  // Створюємо окремий метод для декорації, щоб уникнути дублювання коду
  InputDecoration _inputDecoration({
    required double scaleFactor,
    required String hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFF6B8E6B), size: 22 * scaleFactor)
          : null,
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5FB35F), width: 2),
      ),
      errorBorder: OutlineInputBorder( // Додаємо стиль для рамки з помилкою
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder( // І для рамки з помилкою у фокусі
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(vertical: 16 * scaleFactor),
    );
  }
}