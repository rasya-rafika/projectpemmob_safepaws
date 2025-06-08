import 'package:cloud_firestore/cloud_firestore.dart';

import '../dokter_model.dart';

class DokterService {
  final CollectionReference _dokterCollection = 
      FirebaseFirestore.instance.collection('dokter');

  // Mendapatkan daftar dokter sebagai stream
  Stream<List<Dokter>> getDokterList() {
    return _dokterCollection.snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => Dokter.fromFirestore(doc)).toList());
  }

  // Menambahkan dokter baru
  Future<void> addDokter(Dokter dokter) async {
    await _dokterCollection.doc(dokter.id).set(dokter.toMap());
  }

  // Mengupdate data dokter
  Future<void> updateDokter(Dokter dokter) async {
    await _dokterCollection.doc(dokter.id).update(dokter.toMap());
  }

  // Menghapus dokter
  Future<void> deleteDokter(String dokterId) async {
    await _dokterCollection.doc(dokterId).delete();
  }

  // Mendapatkan detail dokter berdasarkan id
  Future<Dokter?> getDokterById(String dokterId) async {
    DocumentSnapshot doc = await _dokterCollection.doc(dokterId).get();
    if (doc.exists) {
      return Dokter.fromFirestore(doc);
    }
    return null;
  }
}