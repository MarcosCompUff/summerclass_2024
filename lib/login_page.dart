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
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('Desconectado\n${auth.currentUser}');
      } else {
        debugPrint('auth\n${auth.toString()}');
      }
    });

    return Scaffold(
        appBar: AppBar(title: const Text("Login Page")),
        body: Center(
          child: ElevatedButton(onPressed: () async {
            var credential = await signInWithGoogle();
            if (credential != null) {
              debugPrint('credential\n${credential.user}');
              debugPrint('auth\n$auth');
              Navigator.pushNamedAndRemoveUntil(context, '/', arguments: {"credential": credential, "auth": auth}, (route) => false);
            } else {
              debugPrint('Desconectado');
            }
          }, child: Text("Login")),
        ),
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    UserCredential? userCredential;
    if (auth.currentUser != null) {
      try {
        await auth.signOut();
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
      debugPrint('googleUsern${googleUser.toString()}');
      debugPrint('googleAuth\n${googleAuth.toString()}');
      userCredential = await auth.signInWithCredential(credential);
    }
    debugPrint('userCredential\n${userCredential.toString()}');
    debugPrint('auth\n${auth.toString()}');

    return userCredential;
  }
}
