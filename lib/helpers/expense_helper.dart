import 'package:flutter_riverpod/flutter_riverpod.dart';

class Expense {
  final String category;
  final double amount;
  final String title;

  Expense({
    required this.category,
    required this.amount,
    required this.title,
  });
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier();
});

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier() : super([]);

  void addExpense(String category, double amount, String title) {
    state = [
      ...state,
      Expense(category: category, amount: amount, title: title),
    ];
  }

  void removeExpense(int index) {
    state = List.from(state)..removeAt(index);
  }

  void clearExpenses() {
    state = [];
  }
}
