import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    firebaseAuth.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('==============================\nDesconectado\n${firebaseAuth.currentUser}\n==============================');
      } else {
        debugPrint('==============================\nConectado\n${firebaseAuth.currentUser}\n==============================');
      }
    });

    return Scaffold(
        appBar: AppBar(title: const Text("Login Page")),
        body: ElevatedButton(onPressed: signInWithGoogle, child: Text("Login")),
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    UserCredential? userCredential;
    if (firebaseAuth.currentUser != null) {
      try {
        await firebaseAuth.signOut();
      } catch(e) {
        debugPrint("ERRO deslogando:\n$e");
      }
    } else {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      userCredential = await firebaseAuth.signInWithCredential(credential);
    }
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    return userCredential;
  }
}
