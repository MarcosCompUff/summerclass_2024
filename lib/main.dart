import 'package:flutter/material.dart';
import 'package:summerclass_2024/details_page.dart';
import 'package:summerclass_2024/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:summerclass_2024/login_page.dart';
import 'package:summerclass_2024/new_movie.dart';
import 'package:summerclass_2024/update_movie.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // rota '/'
      routes: {
        '/login': (context) => const LoginPage(),
        '/details': (context) => const DetailsPage(),
        '/new': (context) => const NewMoviePage(),
        '/update': (context) => const UpdateMoviePage(),
      },
    );
  }
}
