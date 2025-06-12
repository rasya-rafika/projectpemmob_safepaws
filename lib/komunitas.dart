import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'komunitas_buatpostingan.dart';
import 'komunitas_model.dart';
import 'user_model.dart';

class KomunitasPage extends StatefulWidget {
  final UserRole userRole;
  final String username;

  const KomunitasPage({
    Key? key,
    required this.userRole,
    required this.username,
  }) : super(key: key);

  @override
  State<KomunitasPage> createState() => _KomunitasPageState();
}

class _KomunitasPageState extends State<KomunitasPage> {
  final String namaKomunitas = 'Komunitas Pecinta Hewan';
  final String deskripsiKomunitas =
      'Menjadi catlovers Indonesia dalam mengkampanyekan kebaikan mereka terhadap manusia.';
  final String gambarHeader = 'assets/images/komunitas2.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF661E),
        title: const Text(
          'komunitas pecinta hewan',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // HEADER KOMUNITAS
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                Image.asset(gambarHeader, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaKomunitas,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        deskripsiKomunitas,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 16),
                          const SizedBox(width: 4),
                          const Text("17 rb anggota"),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              // Aksi tombol keluar, misal:
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text("Keluar"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // POSTINGAN FEED
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('posts')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Belum ada postingan."));
                }

                final posts =
                    snapshot.data!.docs
                        .map((doc) {
                          try {
                            return Post.fromFirestore(doc);
                          } catch (e) {
                            print('Gagal parsing post: $e');
                            return null;
                          }
                        })
                        .whereType<Post>()
                        .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPostCard(post);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // FAB TAMBAH POSTINGAN
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF661E),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => KomunitasBuatPostinganPage(
                    username: widget.username, // ✅ kirim username
                  ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${post.username}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
    );
  }
}
