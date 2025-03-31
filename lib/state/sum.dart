import 'package:naukolatek/state/expenses.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'sum.g.dart';

@riverpod
class TotalExpenses extends _$TotalExpenses {
  @override
  double build() {
    var expenses = ref.watch(expensesProvider);
    return expenses.when(
      data: (data) {
        var sum = 0.0;
        for (var expense in data) {
          sum += expense.amount;
        }
        return sum;
      },
      error: (e, s) {
        return 0.0;
      },
      loading: () {
        return 0.0;
      },
    );
  }

  void addExpense(double price) async {
    state = state + price;
  }
}
