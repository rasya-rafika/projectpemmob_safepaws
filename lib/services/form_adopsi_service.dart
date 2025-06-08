import 'package:cloud_firestore/cloud_firestore.dart';
import '../form_adopsi_model.dart';

class FormAdopsiService {
  final _collection = FirebaseFirestore.instance.collection('form_adopsi');

  Future<void> kirimFormAdopsi(FormAdopsi form) async {
    await _collection.doc(form.id).set(form.toMap());
  }

  Stream<List<FormAdopsi>> getAllForms() {
    return _collection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => FormAdopsi.fromMap(doc.id, doc.data()))
        .toList());
  }
}
