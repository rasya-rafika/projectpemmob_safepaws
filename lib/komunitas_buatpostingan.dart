import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'komunitas_inputeditor.dart';

class KomunitasBuatPostinganPage extends StatelessWidget {
  final String username;

  const KomunitasBuatPostinganPage({
    Key? key,
    required this.username,
  }) : super(key: key);

  Future<void> _submitPost(BuildContext context, String text, File? imageFile) async {
    String? imageUrl;

    if (imageFile != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(imageFile);
      imageUrl = await ref.getDownloadURL();
    }

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'username': username,
        'content': text,
        'timestamp': FieldValue.serverTimestamp(),
        'likedBy': [],
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan berhasil ditambahkan!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan postingan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: KomunitasInputEditor(
        hintText: 'Apa yang ingin kamu bagikan?',
        username: username,
        onSend: (text, image) => _submitPost(context, text, image),
      ),
    );
  }
}
