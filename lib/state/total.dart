import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
Future<double> totalExpenses(Ref ref) async {
  final expenses = [];

  return expenses.map((v) => v.price).reduce((a, b) => a + b);
}
