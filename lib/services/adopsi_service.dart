import 'package:cloud_firestore/cloud_firestore.dart';
import '../adopsi_model.dart';

class AdopsiService {
  final _collection = FirebaseFirestore.instance.collection('adopsi');

  Future<void> tambahHewan(HewanAdopsi hewan) async {
    await _collection.add(hewan.toMap());
  }

  Future<List<HewanAdopsi>> getSemuaHewan() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => HewanAdopsi.fromMap(doc.id, doc.data()))
        .toList();
  }
}
