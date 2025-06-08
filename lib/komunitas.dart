import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'komunitas_detail.dart';
import 'komunitas_model.dart';
import 'komunitas_tambah.dart';
import 'user_model.dart';

class KomunitasPage extends StatefulWidget {
  final UserRole userRole;

  const KomunitasPage({Key? key, required this.userRole}) : super(key: key);

  @override
  State<KomunitasPage> createState() => _KomunitasPageState();
}

class _KomunitasPageState extends State<KomunitasPage> {
  int _currentIndex = 0;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'user123';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ExplorePage(currentUserId: currentUserId),
          KomunitaskuPage(
            currentUserId: currentUserId,
            userRole: widget.userRole,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Komunitasku',
          ),
        ],
      ),
    );
  }
}

class ExplorePage extends StatelessWidget {
  final String currentUserId;

  const ExplorePage({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Communities'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('communities')
            .where('members', whereNotIn: [currentUserId])
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
              .toList();

          if (communities.isEmpty) {
            return const Center(
              child: Text('Tidak ada komunitas baru untuk dijelajahi'),
            );
          }

          return ListView.builder(
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              return KomunitasCard(
                community: community,
                currentUserId: currentUserId,
                isJoined: false,
              );
            },
          );
        },
      ),
    );
  }
}

class KomunitaskuPage extends StatelessWidget {
  final String currentUserId;
  final UserRole userRole;

  const KomunitaskuPage({
    Key? key,
    required this.currentUserId,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komunitasku'),
        backgroundColor: Colors.orange,
        actions: [
          if (userRole == UserRole.admin) // hanya admin bisa tambah
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      KomunitasTambahPage(currentUserId: currentUserId),
                ),
              ),
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('communities')
            .where('members', arrayContains: currentUserId)
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
              .toList();

          if (communities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group_add, size: 64, color: Colors.grey),
                  const Text('Belum bergabung dengan komunitas'),
                  const SizedBox(height: 16),
                  if (userRole == UserRole.admin)
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KomunitasTambahPage(currentUserId: currentUserId),
                        ),
                      ),
                      child: const Text('Buat Komunitas'),
                    ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              return KomunitasCard(
                community: community,
                currentUserId: currentUserId,
                isJoined: true,
              );
            },
          );
        },
      ),
    );
  }
}

class KomunitasCard extends StatelessWidget {
  final Community community;
  final String currentUserId;
  final bool isJoined;

  const KomunitasCard({
    Key? key,
    required this.community,
    required this.currentUserId,
    required this.isJoined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAdmin = community.adminId == currentUserId;

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Row(
          children: [
            Text(community.name),
            if (isAdmin) ...[
              const SizedBox(width: 8),
              const Icon(Icons.admin_panel_settings, color: Colors.orange, size: 20),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(community.description),
            Text('${community.members.length} anggota'),
          ],
        ),
        trailing: isJoined
            ? null
            : ElevatedButton(
                onPressed: () => _joinCommunity(),
                child: const Text('Join'),
              ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KomunitasDetailPage(
                community: community,
                currentUserId: currentUserId,
                isJoined: isJoined,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _joinCommunity() async {
    final updatedMembers = [...community.members, currentUserId];
    await FirebaseFirestore.instance
        .collection('communities')
        .doc(community.id)
        .update({'members': updatedMembers});
  }
}