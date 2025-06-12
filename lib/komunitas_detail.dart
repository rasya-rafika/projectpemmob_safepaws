import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'komunitas_buatpostingan.dart';
import 'komunitas_model.dart';
import 'services/komunitas_service.dart';

class KomunitasDetailPage extends StatefulWidget {
  final String komunitasId;
  final String currentUser; // ini UID Firebase
  final String role;

  const KomunitasDetailPage({
    super.key,
    required this.komunitasId,
    required this.currentUser,
    required this.role,
  });

  @override
  State<KomunitasDetailPage> createState() => _KomunitasDetailPageState();
}

class _KomunitasDetailPageState extends State<KomunitasDetailPage> {
  bool isJoined = false;
  List<Post> posts = [];
  bool isLoading = true;
  String currentUsername = '';

  @override
  void initState() {
    super.initState();
    fetchUsername();
    checkIfJoined();
    loadPosts();
  }

  Future<void> fetchUsername() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUser)
        .get();

    if (userDoc.exists) {
      setState(() {
        currentUsername = userDoc.data()?['username'] ?? 'anon';
      });
    }
  }

  Future<void> checkIfJoined() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('komunitas')
        .doc(widget.komunitasId)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      final List<dynamic> members = data['members'] ?? [];

      setState(() {
        isJoined = members.contains(widget.currentUser);
      });
    }
  }

  Future<void> joinKomunitas() async {
    final ref =
        FirebaseFirestore.instance.collection('komunitas').doc(widget.komunitasId);

    await ref.update({
      'members': FieldValue.arrayUnion([widget.currentUser])
    });

    setState(() {
      isJoined = true;
    });
  }

  Future<void> leaveKomunitas() async {
    final ref =
        FirebaseFirestore.instance.collection('komunitas').doc(widget.komunitasId);

    await ref.update({
      'members': FieldValue.arrayRemove([widget.currentUser])
    });

    setState(() {
      isJoined = false;
    });
  }

  Future<void> loadPosts() async {
    final result = await KomunitasService().getAllPosts();
    setState(() {
      posts = result;
      isLoading = false;
    });
  }

  Widget buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${post.username}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(post.content),
            SizedBox(height: 8),
            Text(
              '${post.timestamp.toLocal()}'.split('.')[0],
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Komunitas'),
        backgroundColor: Color(0xFFFF661E),
        actions: [
          if (isJoined)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: leaveKomunitas,
              tooltip: 'Keluar Komunitas',
            )
        ],
      ),
      floatingActionButton: isJoined && currentUsername.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KomunitasBuatPostinganPage(username: currentUsername),
                  ),
                );
                loadPosts();
              },
              child: Icon(Icons.add),
              backgroundColor: Color(0xFFFF661E),
              tooltip: 'Tambah Postingan',
            )
          : null,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!isJoined)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: joinKomunitas,
                      child: Text('Bergabung ke Komunitas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF661E),
                      ),
                    ),
                  ),
                Expanded(
                  child: posts.isEmpty
                      ? Center(child: Text('Belum ada postingan'))
                      : RefreshIndicator(
                          onRefresh: loadPosts,
                          child: ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              return buildPostCard(posts[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}