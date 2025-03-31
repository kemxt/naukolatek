import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naukolatek/helpers/auth.dart';

class UserDataForm extends StatefulWidget {
  const UserDataForm({super.key});

  @override
  State<UserDataForm> createState() => _UserDataFormState();
}

class _UserDataFormState extends State<UserDataForm>
    with SingleTickerProviderStateMixin {
  final authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _incomeController = TextEditingController();
  final _budgetController = TextEditingController();
  final _eduactionController = TextEditingController();
  final _foodController = TextEditingController();
  final _hobbyController = TextEditingController();
  final _otherController = TextEditingController();
  final _workController = TextEditingController();
  final _healthController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _incomeController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveFinancialData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Parsowanie wartości z kontrolerów
        double income =
            double.parse(_incomeController.text.replaceAll(',', '.'));
        double budget =
            double.parse(_budgetController.text.replaceAll(',', '.'));
        double education =
            double.parse(_eduactionController.text.replaceAll(',', '.'));
        double food = double.parse(_foodController.text.replaceAll(',', '.'));
        double health =
            double.parse(_healthController.text.replaceAll(',', '.'));
        double hobby = double.parse(_hobbyController.text.replaceAll(',', '.'));
        double work = double.parse(_workController.text.replaceAll(',', '.'));
        double other = double.parse(_otherController.text.replaceAll(',', '.'));

        final targets = {
          "education": education,
          "food": food,
          "health": health,
          "hobby": hobby,
          "work": work,
          "other": other
        };
        await authService.saveUserFinancialData(income, budget, targets);

        // Przekierowanie do strony głównej po zapisaniu danych
        if (mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Błąd zapisywania danych: $e')),
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
  }

// Pomocnicza metoda do walidacji wprowadzanych liczb
  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'To pole jest wymagane';
    }

    // Zamiana przecinka na kropkę do walidacji
    String normalizedValue = value.replaceAll(',', '.');

    try {
      double parsedValue = double.parse(normalizedValue);
      if (parsedValue <= 0) {
        return 'Wartość musi być większa niż 0';
      }
    } catch (e) {
      return 'Wprowadź poprawną wartość liczbową';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Uzupełnij swoje dane',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _animationController.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ostatni krok!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aby dostosować aplikację do Twoich potrzeb, potrzebujemy informacji o Twoich finansach.',
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
                        _buildFinancialField(
                          label: 'Miesięczny przychód',
                          hintText: 'Np. 5000',
                          controller: _incomeController,
                          icon: Icons.attach_money,
                        ),
                        const SizedBox(height: 24),
                        _buildFinancialField(
                          label: 'Planowany budżet miesięczny',
                          hintText: 'Np. 3500',
                          controller: _budgetController,
                          icon: Icons.account_balance_wallet,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Budżet to kwota, którą planujesz wydać miesięcznie. Pomoże nam to śledzić Twoje wydatki w stosunku do planów.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        _buildFinancialField(
                          label: 'Edukacja',
                          hintText: 'Np. 200',
                          controller: _eduactionController,
                          icon: Icons.attach_money,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        _buildFinancialField(
                          label: 'Jedzenie',
                          hintText: 'Np. 800',
                          controller: _foodController,
                          icon: Icons.attach_money,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        _buildFinancialField(
                          label: 'Praca',
                          hintText: 'Np. 200',
                          controller: _workController,
                          icon: Icons.attach_money,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        _buildFinancialField(
                          label: 'Zainteresowania',
                          hintText: 'Np. 200',
                          controller: _hobbyController,
                          icon: Icons.attach_money,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        _buildFinancialField(
                          label: 'Zdrowie',
                          hintText: 'Np. 500',
                          controller: _healthController,
                          icon: Icons.attach_money,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        _buildFinancialField(
                          label: 'Inne',
                          hintText: 'Np. 300',
                          controller: _otherController,
                          icon: Icons.attach_money,
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveFinancialData,
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
                                  'Zapisz i kontynuuj',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'Dane możesz później zmienić w ustawieniach',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: _validateNumber,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: Colors.black54),
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
        ),
      ],
    );
  }
}
