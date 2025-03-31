import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naukolatek/helpers/auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Tutaj dodaj logikę logowania przez email
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);

        var credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
        print(credential.user);
        print(_emailController.text);
        print(_passwordController.text);
        bool isNew = await authService.isNewUser();

        if (isNew) {
          context.go('/onboarding');
        } else {
          context.go('/home');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd logowania: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await authService.signInWithGoogle();

      bool isNew = await authService.isNewUser();

      if (isNew) {
        // Jeśli użytkownik jest nowy, przekieruj go do formularza onboardingowego
        context.go('/onboarding');
      } else {
        // Jeśli użytkownik już istnieje, przekieruj go do strony głównej
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd logowania przez Google: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 70),
                    Text(
                      'Witaj!',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Zaloguj się do swojego konta lub stwórz nowe',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'Adres email',
                            prefixIcon: Icons.email_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Wprowadź adres email';
                              }
                              if (!value.contains('@')) {
                                return 'Wprowadź poprawny adres email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: 'Hasło',
                            prefixIcon: Icons.lock_outline,
                            obscureText: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Wprowadź hasło';
                              }
                              if (value.length < 6) {
                                return 'Hasło musi mieć co najmniej 6 znaków';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Dodaj obsługę przycisku "Zapomniałeś hasła?"
                              },
                              child: const Text(
                                'Zapomniałeś hasła?',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signInWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1,
                            ),
                            child: _isLoading
                                ? const CupertinoActivityIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'Zaloguj się',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'lub',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            onPressed: _isLoading ? null : _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Colors.grey, width: 1),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Image.asset(
                              'lib/assets/google_logo.png',
                              height: 20,
                            ),
                            label: const Text(
                              'Kontynuuj z Google',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Nie masz jeszcze konta?',
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            // Przekierowanie do ekranu rejestracji
                            // context.go('/register');
                          },
                          child: const Text(
                            'Zarejestruj się',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: Colors.black54),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
