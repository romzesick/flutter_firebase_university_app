import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Serwis odpowiedzialny za autoryzację użytkownika i komunikację z Firebase
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Strumień nasłuchujący zmian stanu autoryzacji (logowania)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Logowanie użytkownika przy użyciu e-maila i hasła
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Rejestracja nowego użytkownika i zapis jego danych w Firestore
  Future<void> signUp(
    String email,
    String password,
    String name,
    int age,
  ) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'age': age,
        'email': email,
      });
    }
  }

  /// Wysyłanie e-maila do zresetowania hasła
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Wylogowanie użytkownika
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Usunięcie konta aktualnie zalogowanego użytkownika
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }
}
