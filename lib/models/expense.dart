import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String category;
  double amount;
  String title;
  final String? id;
  final Timestamp? timestamp;

  Expense(
      {required this.category,
      required this.amount,
      required this.title,
      this.id,
      this.timestamp});

  // Dodaj metodę fromJson
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
        category: json['category'] as String,
        amount: json['amount'] as double,
        title: json['title'] as String,
        id: json['id'] as String?,
        timestamp: json['timestamp'] as Timestamp?);
  }
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'title': title,
      'id': id,
      'timestamp': timestamp,
    };
  }

  Expense copyWith({
    String? category,
    double? amount,
    String? title,
    String? id,
    Timestamp? timestamp,
  }) {
    return Expense(
      category: category ?? this.category,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
