import 'package:cloud_firestore/cloud_firestore.dart';

import '../adopsi_model.dart';

class AdopsiService {
  final _collection = FirebaseFirestore.instance.collection('adopsi');

  /// Menambah hewan adopsi dengan ID manual agar bisa disimpan kembali
  Future<void> tambahHewan(HewanAdopsi hewan) async {
    await _collection.doc(hewan.id).set(hewan.toMap());
  }

  /// Stream real-time data hewan adopsi
  Stream<List<HewanAdopsi>> streamHewanAdopsi() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => HewanAdopsi.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Mengambil semua data (tidak real-time, jika dibutuhkan)
  Future<List<HewanAdopsi>> getSemuaHewan() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => HewanAdopsi.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Update data hewan
  Future<void> updateHewan(HewanAdopsi hewan) async {
    await _collection.doc(hewan.id).update(hewan.toMap());
  }

  /// Hapus data hewan
  Future<void> deleteHewan(String id) async {
    await _collection.doc(id).delete();
  }
}
