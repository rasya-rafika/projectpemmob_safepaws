import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'komunitas_model.dart';

class KomentarPage extends StatefulWidget {
  final Post post;
  final String currentUsername;

  const KomentarPage({
    Key? key,
    required this.post,
    required this.currentUsername,
  }) : super(key: key);

  @override
  State<KomentarPage> createState() => _KomentarPageState();
}

class _KomentarPageState extends State<KomentarPage> {
  final TextEditingController _controller = TextEditingController();
  File? _pickedImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  void _kirimKomentar() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _pickedImage == null) return;

    String? imageUrl;

    if (_pickedImage != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('komentar_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(_pickedImage!);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('komentar')
        .add({
      'content': text,
      'username': widget.currentUsername,
      'timestamp': Timestamp.now(),
      'imageUrl': imageUrl, // boleh null
    });

    _controller.clear();
    setState(() {
      _pickedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF661E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Komentar', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Postingan utama
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '@${widget.post.username}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.post.timestamp.day}/${widget.post.timestamp.month}/${widget.post.timestamp.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.post.content),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.favorite_border, size: 18),
                      const SizedBox(width: 4),
                      Text('${widget.post.likedBy.length}'),
                      const SizedBox(width: 16),
                      const Icon(Icons.comment, size: 18),
                      const SizedBox(width: 4),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .doc(widget.post.id)
                            .collection('komentar')
                            .snapshots(),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.docs.length ?? 0;
                          return Text('$count');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // List komentar
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.post.id)
                  .collection('komentar')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final komentar = snapshot.data!.docs;

                if (komentar.isEmpty) {
                  return const Center(child: Text("Belum ada komentar."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: komentar.length,
                  itemBuilder: (context, index) {
                    final data = komentar[index].data() as Map<String, dynamic>;
                    final imageUrl = data['imageUrl'];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      title: Text(
                        '@${data['username'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((data['content'] ?? '').toString().isNotEmpty)
                            Text(data['content']),
                          if (imageUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(imageUrl, height: 150),
                              ),
                            ),
                        ],
                      ),
                      trailing: data['username'] == widget.currentUsername
                          ? PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'hapus') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Hapus Komentar?'),
                                      content: const Text(
                                          'Komentar akan dihapus secara permanen.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Hapus',
                                              style: TextStyle(
                                                  color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(widget.post.id)
                                        .collection('komentar')
                                        .doc(komentar[index].id)
                                        .delete();
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'hapus',
                                  child: Text('Hapus'),
                                ),
                              ],
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),

          // Preview gambar jika ada
          if (_pickedImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                children: [
                  Image.file(_pickedImage!, height: 150),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _pickedImage = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Input komentar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: const Border(top: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.grey),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Posting balasan Anda',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
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
