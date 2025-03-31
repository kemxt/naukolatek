import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naukolatek/state/sum.dart';
import 'package:naukolatek/styles/style.dart';

class TotalSpentWidget extends ConsumerWidget {
  final double scale;
  const TotalSpentWidget({Key? key, required this.scale}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSpent = ref.watch(totalExpensesProvider);

    return Transform.scale(
      scale: scale, // Reaktywna skala napisu
      child: Padding(
        padding:
            EdgeInsets.symmetric(vertical: 8 * scale), // Dynamiczny padding
        child: Text(
          'Wydano: ${totalSpent.toStringAsFixed(2)}zł',
          style: h2.copyWith(
            fontSize: 20 * scale, // Skalowanie czcionki
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
