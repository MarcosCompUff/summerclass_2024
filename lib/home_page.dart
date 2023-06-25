import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  bool isLoading = true;
  List<Map<String, dynamic>> moviesList = [];
  List<String> titles = [];
  List<Widget> images = [];

  @override
  initState() {
    super.initState();
    if (auth.currentUser == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login',(route) => false);
    }
    reloadData();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    // Map<String, dynamic>? arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    // User? user = arguments?["credential"].user;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Filmes nacionais'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: reloadData, icon: const Icon(Icons.refresh)),
        ],
        leading: InkWell(
          onTap: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          child: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(auth.currentUser!.photoURL!),
          ),
        ),
      ),
      body: auth.currentUser == null
        ? const Center(
            child: Text("Você precisa estar logado para continuar",
            style: TextStyle(color: Colors.white,),),
        )
        : isLoading
          ? const Center(child: CircularProgressIndicator())
          : VerticalCardPager(
            initialPage: 1,
            titles: titles,
            images: images,
            onSelectedItem: onSelectedItem,
          ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: Text('Login'),
                onTap: () {
                  debugPrint('Login');
                },
              ),
              ListTile(
                title: Text('Testar'),
                onTap: () {
                  debugPrint('Testando');
                },
              ),
            ],
          ),
        ),
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
