import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:summerclass_2024/login_page.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  bool isLoading = true;
  List<Map<String, dynamic>> moviesList = [];
  List<String> titles = [];
  List<Widget> images = [];

  @override
  initState() {
    super.initState();
    if (firebaseAuth.currentUser == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
    reloadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Filmes nacionais'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: reloadData, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: LoginPage.signInWithGoogle, icon: const Icon(Icons.account_circle_outlined))
        ],
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : VerticalCardPager(
          initialPage: 1,
          titles: titles,
          images: images,
          onSelectedItem: onSelectedItem,
        ),
    );
  }

  Future<void>getAll() async {
    try{
      List<Map<String, dynamic>> moviesList = [];
      await db.collection("movies").get().then((querySnapshot) async {
        final docs = querySnapshot.docs;
        for (var index = 0; index < docs.length; index++) {
          final docSnapshot = docs[index];
          Map<String, dynamic> movie = {};
          movie["index"] = index;
          movie["id"] = docSnapshot.id;
          movie["titulo"] = docSnapshot.data()["titulo"];
          movie["diretor"] = docSnapshot.data()["diretor"];
          movie["sinopse"] = docSnapshot.data()["sinopse"];
          movie["liked"] = docSnapshot.data()["liked"];
          movie["image"] = await storage.ref().child(docSnapshot.data()["image"]).getData();
          moviesList.add(movie);
        }
      }, onError: (e) {
        debugPrint("Error completing: $e");
      });
      // debugPrint("MovieList: $moviesList");
      this.moviesList = moviesList;
    } catch(e) {
      debugPrint('ERRO db.collection("movies").get(): $e');
    }
  }

  Future<void> fillMovieInfo(List movieList) async {
    int i = 1;
    for(var movie in movieList ){
      titles.add("");
      images.add(
        Hero(
          tag: i,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image.memory(
              movie["image"],
              fit: BoxFit.cover,
            ),
          ),
        )
      );
      i++;
    }
    // Adiciona um card de adicionar depois da lista de filmes
    titles.add("");
    images.add(
      Hero(
        tag: i,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: const Icon(Icons.add_box_rounded, color: Colors.blue, size: 200)
        ),
      ),
    );
  }

  Future<void> reloadData() async {
    setState(() {
      isLoading = true;
    });

    titles = [];
    images = [];
    await getAll();
    fillMovieInfo(moviesList);

    setState(() {
      isLoading = false;
    });
  }

  void onSelectedItem(int index) {
    debugPrint("Index clicado: $index | MovieList length: ${moviesList.length}");
    if (index == moviesList.length){
      Navigator.pushNamed(context, '/new');
    } else {
      Navigator.pushNamed(context, '/details', arguments: moviesList[index]);
    }
  }
}
