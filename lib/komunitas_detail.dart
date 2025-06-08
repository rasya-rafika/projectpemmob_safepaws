import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'komunitas_model.dart';
import 'post_card.dart';
import 'post_model.dart';


class KomunitasDetailPage extends StatefulWidget {
  final Community community;
  final String currentUserId;
  final bool isJoined;

  const KomunitasDetailPage({
    Key? key,
    required this.community,
    required this.currentUserId,
    required this.isJoined,
  }) : super(key: key);

  @override
  _KomunitasDetailPageState createState() => _KomunitasDetailPageState();
}

class _KomunitasDetailPageState extends State<KomunitasDetailPage> {
  final TextEditingController _postController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.community.adminId == widget.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.community.name),
        backgroundColor: Colors.orange,
        actions: [
          if (isAdmin)
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'members',
                  child: Row(
                    children: [
                      Icon(Icons.people),
                      SizedBox(width: 8),
                      Text('Lihat Anggota'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit Komunitas'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus Komunitas', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'members':
                    _showMembersDialog();
                    break;
                  case 'edit':
                    _showEditDialog();
                    break;
                  case 'delete':
                    _showDeleteConfirmation();
                    break;
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Community Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.group,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.community.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.community.members.length} anggota',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.admin_panel_settings,
                        color: Colors.orange.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Admin',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Join Button if not joined
          if (!widget.isJoined)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _joinCommunity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Gabung Komunitas',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          
          const Divider(height: 1),
          
          // Posts Section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('communityId', isEqualTo: widget.community.id)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!.docs
                    .map((doc) => Post.fromFirestore(doc))
                    .toList();

                if (posts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.post_add, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada postingan',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Jadilah yang pertama untuk berbagi!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return PostCard(
                      post: posts[index],
                      currentUserId: widget.currentUserId,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isJoined
          ? FloatingActionButton(
              onPressed: _showCreatePostDialog,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _joinCommunity() async {
    try {
      final updatedMembers = [...widget.community.members, widget.currentUserId];
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.community.id)
          .update({'members': updatedMembers});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil bergabung dengan komunitas!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Postingan'),
        content: TextField(
          controller: _postController,
          decoration: const InputDecoration(
            hintText: 'Tulis sesuatu...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          maxLength: 500,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_postController.text.trim().isNotEmpty) {
                await _createPost();
                Navigator.pop(context);
                _postController.clear();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPost() async {
    try {
      final post = Post(
        id: '',
        authorId: widget.currentUserId,
        authorName: 'User ${widget.currentUserId.substring(0, 6)}', // Simplified
        content: _postController.text.trim(),
        communityId: widget.community.id,
        likes: [],
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('posts')
          .add(post.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Postingan berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMembersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anggota Komunitas'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.community.members.length,
            itemBuilder: (context, index) {
              final memberId = widget.community.members[index];
              final isAdmin = memberId == widget.community.adminId;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Text(
                    memberId.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                title: Text('User ${memberId.substring(0, 6)}'),
                trailing: isAdmin
                    ? const Text(
                        'Admin',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final TextEditingController nameController =
        TextEditingController(text: widget.community.name);
    final TextEditingController descController =
        TextEditingController(text: widget.community.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Komunitas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Komunitas'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('communities')
                    .doc(widget.community.id)
                    .update({
                  'name': nameController.text.trim(),
                  'description': descController.text.trim(),
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Komunitas berhasil diperbarui!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Komunitas'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus komunitas ini? Semua postingan akan ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Hapus komunitas
                await FirebaseFirestore.instance
                    .collection('communities')
                    .doc(widget.community.id)
                    .delete();

                // Hapus semua postingan terkait komunitas ini
                final postsSnapshot = await FirebaseFirestore.instance
                    .collection('posts')
                    .where('communityId', isEqualTo: widget.community.id)
                    .get();

                for (final doc in postsSnapshot.docs) {
                  await doc.reference.delete();
                }

                if (mounted) {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Komunitas berhasil dihapus.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}