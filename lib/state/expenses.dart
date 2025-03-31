import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:naukolatek/models/expense.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expenses.g.dart';

@riverpod
class Expenses extends _$Expenses {
  @override
  Stream<List<Expense>> build() {
    return FirebaseFirestore.instance
        .collection('expenses')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_expenses')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromJson(doc.data()).copyWith(id: doc.id))
            .toList());
  }

  Future<void> addExpense(String title, double amount, String category) async {
    var firestore = FirebaseFirestore.instance;
    var uid = FirebaseAuth.instance.currentUser!.uid;
    var expense = Expense(
      category: category,
      amount: amount,
      title: title,
    );

    await firestore
        .collection('expenses')
        .doc(uid)
        .collection('user_expenses')
        .add(expense.toJson());

    print('Succesfully added new expense!');
  }

  Future<void> removeExpense(String id) async {
    var firestore = FirebaseFirestore.instance;
    var uid = FirebaseAuth.instance.currentUser!.uid;

    await firestore
        .collection('expenses')
        .doc(uid)
        .collection('user_expenses')
        .doc(id)
        .delete();
    print('Succesfully removed expense!');
  }
}
