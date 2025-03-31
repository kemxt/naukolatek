import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _firestore = FirebaseFirestore.instance;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<bool> isNewUser() async {
    try {
      var uid = FirebaseAuth.instance.currentUser?.uid;

      var userDocRef =
          FirebaseFirestore.instance.collection(uid!).doc('userData');
      var docSnapshot = await userDocRef.get();

      return !docSnapshot.exists;
    } catch (e) {
      print('Błąd podczas sprawdzania użytkownika: $e');
      // W przypadku błędu, bezpieczniej założyć, że użytkownik jest nowy
      return true;
    }
  }

  Future<void> saveUserFinancialData(
      double income, double budget, Map<String, double> categories) async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("Użytkownik nie jest zalogowany");
    }

    // Referencja do dokumentu użytkownika
    DocumentReference userRef =
        _firestore.collection(currentUser.uid).doc('userData');

    Map<String, dynamic> financialData = {
      'income': income,
      'budget': budget,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
    final combined = {...financialData, ...categories};
    // Sprawdź, czy dokument istnieje
    DocumentSnapshot userDoc = await userRef.get();

    if (userDoc.exists) {
      await userRef.update(combined);
    } else {
      // Dodaj dodatkowe informacje dla nowego użytkownika
      financialData['createdAt'] = FieldValue.serverTimestamp();
      financialData['email'] = currentUser.email;
      financialData['displayName'] = currentUser.displayName;
      financialData['photoURL'] = currentUser.photoURL;

      // Utwórz nowy dokument
      await userRef.set(combined);
    }
  }

  // Pobieranie danych finansowych użytkownika
  Future<Map<String, dynamic>?> getUserFinancialData() async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("Użytkownik nie jest zalogowany");
    }

    DocumentSnapshot userDoc =
        await _firestore.collection(currentUser.uid).doc('userData').get();

    if (!userDoc.exists) {
      return null;
    }

    return userDoc.data() as Map<String, dynamic>?;
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      // Uzyskaj poświadczenia uwierzytelniania
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Utwórz nowe poświadczenia dla Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      await setupFirestore(userCredential.user!.uid);
      return userCredential.user?.uid;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> setupFirestore(String userID) async {
    try {
      var firestore = FirebaseFirestore.instance;
      var randomCollectionId = firestore.collection(userID).doc().id;
      await firestore
          .collection(userID)
          .doc('userData')
          .collection('credentials')
          .add({'name': currentUser!.displayName});
    } catch (e) {
      print("error $e");
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
