import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'komunitas_model.dart';

class KomunitasPostinganPage extends StatefulWidget {
  final Post post;
  final String currentUsername;

  const KomunitasPostinganPage({
    Key? key,
    required this.post,
    required this.currentUsername,
  }) : super(key: key);

  @override
  State<KomunitasPostinganPage> createState() => _KomunitasPostinganPageState();
}

class _KomunitasPostinganPageState extends State<KomunitasPostinganPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _kirimKomentar() async {
    final konten = _commentController.text.trim();
    if (konten.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('komentar')
        .add({
      'username': widget.currentUsername,
      'konten': konten,
      'timestamp': Timestamp.now(),
    });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF661E),
        title: const Text("Detail Postingan", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('@${post.username}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(post.content),
                  const SizedBox(height: 8),
                  Text(
                    '${post.timestamp.day}/${post.timestamp.month}/${post.timestamp.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Komentar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(post.id)
                  .collection('komentar')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final komentar = snapshot.data!.docs;

                if (komentar.isEmpty) {
                  return const Center(child: Text("Belum ada komentar."));
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: komentar.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('@${data['username'] ?? ''}'),
                      subtitle: Text(data['konten'] ?? ''),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Posting balasan Anda',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF661E)),
                  onPressed: _kirimKomentar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}