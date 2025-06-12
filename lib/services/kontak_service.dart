import 'package:cloud_firestore/cloud_firestore.dart';
import '../kontak_model.dart';

class KontakService {
  final _collection = FirebaseFirestore.instance.collection('kontak_user');

  Future<void> kirimPesan(KontakPesan pesan) async {
    await _collection.doc(pesan.id).set(pesan.toMap());
  }

  Stream<List<KontakPesan>> streamPesan() {
    return _collection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => KontakPesan.fromMap(doc.id, doc.data())).toList());
  }
}
