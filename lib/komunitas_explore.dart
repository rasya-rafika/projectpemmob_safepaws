import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'komunitas_card.dart';  // widget untuk tampilkan komunitas
import 'komunitas_model.dart'; // pastikan ini sesuai

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Communities'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('communities')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final communities = snapshot.data!.docs
              .map((doc) => Community.fromFirestore(doc))
              .where((komunitas) => !komunitas.members.contains(currentUserId))
              .toList();

          if (communities.isEmpty) {
            return const Center(
              child: Text('Tidak ada komunitas baru untuk dijelajahi'),
            );
          }

          return ListView.builder(
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final komunitas = communities[index];
              return KomunitasCard(
                komunitas: komunitas,
                isJoined: false,
              );
            },
          );
        },
      ),
    );
  }
}
