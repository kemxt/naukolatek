import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naukolatek/models/CategoryConstants.dart';
import 'package:naukolatek/state/expenses.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'categorySum.g.dart';

// @riverpod
// class CategorySum extends _$CategorySum {
//   @override
//   double build() {
//     var expenses = ref.watch(expensesProvider);
//     return expenses.when(
//       data: (data) {
//         var sum = 0.0;
//         for (var expense in data) {
//           for (var category in categoryConstants) {
//             if (expense.category == category) {
//               print('zgadza sie xd');
//             }
//           }
//         }
//         return sum;
//       },
//       error: (e, s) {
//         return 0.0;
//       },
//       loading: () {
//         return 0.0;
//       },
//     );
//   }
// }
@riverpod
double categorySum(CategorySumRef ref, String category) {
  var expenses = ref.watch(expensesProvider);

  return expenses.when(
    data: (data) {
      var sum = 0.0;
      for (var expense in data) {
        if (expense.category == category) {
          sum += expense.amount;
        }
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
