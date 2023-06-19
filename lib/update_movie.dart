import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class UpdateMoviePage extends StatefulWidget {
  const UpdateMoviePage({super.key});

  @override
  State<UpdateMoviePage> createState() => _UpdateMoviePageState();
}

class _UpdateMoviePageState extends State<UpdateMoviePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> movie = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String fileName = movie["id"];
    String titulo = movie["titulo"];
    String diretor = movie["diretor"];
    String sinopse = movie["sinopse"];
    File? imagePath = movie["imagePath"];
    Uint8List imageBytes = movie["image"];

    return Scaffold(
        appBar: AppBar(title: const Text("Update Movie Page")),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: titulo,
                onSaved: (String? value) {
                  if (value == null || value.isEmpty) {
                    titulo = "Título pendente";
                  } else {
                    titulo = value;
                  }
                },
              ),
              TextFormField(
                initialValue: diretor,
                onSaved: (String? value) {
                  if (value == null || value.isEmpty) {
                    diretor = "Diretor pendente";
                  } else {
                    diretor = value;
                  }
                },
              ),
              TextFormField(
                initialValue: sinopse,
                onSaved: (String? value) {
                  if (value == null || value.isEmpty) {
                    sinopse = "Sinopse pendente";
                  } else {
                    sinopse = value;
                  }
                },
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: InkWell (
                    onTap: () => imagePicker(movie, imageBytes, imagePath),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: MemoryImage(imageBytes),
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: 100,
                      height: 100,
                    )
                  )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate retorna true se o form for válido
                    if (_formKey.currentState!.validate()) {
                      // Process data.
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Salvando...')));
                      _formKey.currentState!.save();
                      await updateMovie(fileName, titulo, diretor, sinopse, imagePath);
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ),
              // ElevatedButton(onPressed: controller.printAll, child: const Text("Print")),
            ],
          ),
        )
    );
  }

  // Future<void> loadAssetImage() async {
  //   final directory = await getTemporaryDirectory();
  //   final imagePath = '${directory.path}/claquete.png';
  //   this.imagePath = File(imagePath);
  // }

  imagePicker(Map<String, dynamic> movie, Uint8List imageBytes, File? imagePath) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        movie["image"] = imageBytes;
      });
      movie["imagePath"] = File(pickedFile.path);
    }
  }

  updateMovie(String fileName, String titulo, String diretor, String sinopse, File? imagePath) async {
    final ref = storage.ref().child(fileName); // criando referência
    if (imagePath != null) {
      await ref.putFile(imagePath); // salvando imagem
    }

    Map<String, dynamic> movie = {
      "titulo": titulo,
      "diretor": diretor,
      "sinopse": sinopse,
      "image": fileName,
      "liked": false,
    };

    await db.collection("movies").doc(fileName).set(movie); // salvando filme
  }
}
