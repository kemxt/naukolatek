import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'user_goals.g.dart';

@riverpod
class userGoals extends _$userGoals {
  Future<DocumentSnapshot<Map<String, dynamic>>> build() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    return await FirebaseFirestore.instance
        .collection(user.uid)
        .doc('userData')
        .get();
  }
}
