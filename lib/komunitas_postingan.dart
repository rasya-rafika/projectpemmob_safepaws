import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KomunitasPostinganPage extends StatelessWidget {
  final String komunitasId;

  const KomunitasPostinganPage({Key? key, required this.komunitasId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('komunitas')
          .doc(komunitasId)
          .collection('postingan')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(child: Text('Belum ada postingan.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(data['judul'] ?? ''),
                subtitle: Text(data['isi'] ?? ''),
                trailing: Text(
                  (data['timestamp'] as Timestamp?)?.toDate().toLocal().toString().split('.')[0] ?? '',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            );
          },
        );
      },
    );
  }
}