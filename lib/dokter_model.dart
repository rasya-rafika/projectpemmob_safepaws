import 'package:cloud_firestore/cloud_firestore.dart';

class Dokter {
  final String id;
  final String nama;
  final String pengalaman;
  final String lokasi;

  Dokter({
    required this.id,
    required this.nama,
    required this.pengalaman,
    required this.lokasi,
  });

  // Factory method untuk membuat Dokter dari Firestore document
  factory Dokter.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Dokter(
      id: doc.id,
      nama: data['nama'] ?? '',
      pengalaman: data['pengalaman'] ?? '',
      lokasi: data['lokasi'] ?? '',
    );
  }

  // Method untuk mengonversi Dokter ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'pengalaman': pengalaman,
      'lokasi': lokasi,
    };
  }
}