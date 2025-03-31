import 'package:flutter/material.dart';

Widget decideLogo(dynamic category) {
  if (category is! String) {
    print('Invalid category type: $category (${category.runtimeType})');
    return CircleAvatar(
      backgroundColor: Colors.red,
      child: const Icon(Icons.error, color: Colors.white),
    );
  }
  switch (category) {
    case 'Jedzenie':
      return CircleAvatar(
        backgroundColor: Colors.green,
        child: const Icon(Icons.fastfood, color: Colors.white),
      );
    case 'Zainteresowania':
      return CircleAvatar(
        backgroundColor: Colors.red,
        child: const Icon(Icons.movie, color: Colors.white),
      );
    case 'Edukacja':
      return CircleAvatar(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.school, color: Colors.white),
      );
    case 'Zdrowie':
      return CircleAvatar(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.health_and_safety, color: Colors.white),
      );
    default:
      return CircleAvatar(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.category, color: Colors.white),
      );
  }
}
