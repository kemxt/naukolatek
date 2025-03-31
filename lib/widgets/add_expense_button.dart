import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddExpenseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return TextButton(
          onPressed: () {
            print("xddd");
          },
          child: const Text('Add'),
        );
      },
    );
  }
}
