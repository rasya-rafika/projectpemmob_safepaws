import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'komunitas_buatpostingan.dart';
import 'komunitas_komentar.dart';
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
      'Komunitas Pecinta Hewan adalah tempat kumpul buat kamu yang sayang banget sama hewan. Bisa sharing, tanya-tanya, atau sekadar seru-seruan bareng sesama penyayang hewan.';
  final String gambarHeader = 'assets/images/komunitaspage.jpg';

  final Map<String, bool> _expandedComments = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFFF661E),
            expandedHeight: 60,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Safepaws Komunitas',
              style: TextStyle(color: Colors.white),
            ),
          ),

          SliverToBoxAdapter(
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
                        children: const [
                          Icon(Icons.people, size: 16),
                          SizedBox(width: 4),
                          Text("17 rb anggota"),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('posts')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text("Belum ada postingan.")),
                  );
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
                  padding: const EdgeInsets.all(12),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF661E),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      KomunitasBuatPostinganPage(username: widget.username),
            ),
          );

          if (result == true) {
            // Optional: setState kalau perlu trigger build
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => KomentarPage(
                    post: post,
                    currentUsername: widget.username,
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '@${post.username}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'hapus') {
                        _confirmHapus(post.id);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'hapus',
                            child: Text('Hapus'),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(post.content),
              const SizedBox(height: 8),
              Text(
                '${post.timestamp.day}/${post.timestamp.month}/${post.timestamp.year}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.likedBy.contains(widget.username)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          post.likedBy.contains(widget.username)
                              ? Colors.red
                              : Colors.black,
                      size: 20,
                    ),
                    onPressed: () => _toggleLike(post),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  Text('${post.likedBy.length}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment, size: 20),
                  const SizedBox(width: 4),
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('posts')
                            .doc(post.id)
                            .collection('komentar')
                            .snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return Text('$count');
                    },
                  ),
                ],
              ),
              if (_expandedComments[post.id] == true)
                _buildKomentarList(post.id),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleKomentar(String postId) {
    setState(() {
      _expandedComments[postId] = !(_expandedComments[postId] ?? false);
    });
  }

  Widget _buildKomentarList(String postId) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('komentar')
              .orderBy('timestamp', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final komentar = snapshot.data!.docs;
        return Column(
          children:
              komentar.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('@${data['username'] ?? ''}'),
                  subtitle: Text(data['konten'] ?? ''),
                );
              }).toList(),
        );
      },
    );
  }

  void _toggleLike(Post post) async {
    final docRef = FirebaseFirestore.instance.collection('posts').doc(post.id);
    final isLiked = post.likedBy.contains(widget.username);

    await docRef.update({
      'likedBy':
          isLiked
              ? FieldValue.arrayRemove([widget.username])
              : FieldValue.arrayUnion([widget.username]),
    });
  }

  void _confirmHapus(String postId) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Hapus Postingan"),
            content: const Text("Yakin ingin menghapus postingan ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .delete();
                  Navigator.pop(ctx);
                },
                child: const Text("Hapus"),
              ),
            ],
          ),
    );
  }
}
