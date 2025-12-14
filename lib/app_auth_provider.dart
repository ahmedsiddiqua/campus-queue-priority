import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AppAuthProvider extends ChangeNotifier {
  User? get user => FirebaseAuth.instance.currentUser;
  String? get email => user?.email;
  String? get uid => user?.uid;

  // -----------------------------
  // LOGIN (Email + Password)
  // -----------------------------
  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Force fresh auth token for Cloud Functions
    await FirebaseAuth.instance.currentUser?.getIdToken(true);

    notifyListeners();
  }

  // -----------------------------
  // REGISTER → Creates Firestore doc using UID
  // -----------------------------
  Future<void> register(String email, String password) async {
    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    final user = cred.user;
    if (user == null) return;

    await user.getIdToken(true);

    // Store user doc using UID
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set({
      "role": "student",
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "email": user.email,
    }, SetOptions(merge: true));

    notifyListeners();
  }

  // -----------------------------
  // LOGIN WITH GOOGLE
  // -----------------------------
  Future<void> loginWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      clientId:
          "939511938752-266nokctemq14qe0ph2j3i9v7ttdp3g8.apps.googleusercontent.com",
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final user = userCred.user;
    if (user == null) return;

    await user.getIdToken(true);

    // Ensure a user doc exists (UID-based)
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set({
      "role": "student",
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "email": user.email,
    }, SetOptions(merge: true));

    notifyListeners();
  }

  // -----------------------------
  // LOGOUT
  // -----------------------------
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}
