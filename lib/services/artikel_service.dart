import 'package:cloud_firestore/cloud_firestore.dart';
import '../artikel_model.dart';

class ArtikelService {
  final _collection = FirebaseFirestore.instance.collection('artikel');

  Future<void> tambahArtikel(Artikel artikel) async {
    await _collection.doc(artikel.id).set(artikel.toMap());
  }

  Future<void> hapusArtikel(String id) async {
    await _collection.doc(id).delete();
  }

  Stream<List<Artikel>> ambilArtikelStream() {
    return _collection.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => Artikel.fromMap(doc.id, doc.data())).toList());
  }
}
