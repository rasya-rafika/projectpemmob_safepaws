import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KomunitasBuatPostinganPage extends StatefulWidget {
  final String komunitasId;

  const KomunitasBuatPostinganPage({Key? key, required this.komunitasId}) : super(key: key);

  @override
  State<KomunitasBuatPostinganPage> createState() => _KomunitasBuatPostinganPageState();
}

class _KomunitasBuatPostinganPageState extends State<KomunitasBuatPostinganPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await FirebaseFirestore.instance
          .collection('komunitas')
          .doc(widget.komunitasId)
          .collection('postingan')
          .add({
        'judul': _judulController.text.trim(),
        'isi': _isiController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // Kembali ke halaman sebelumnya
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buat Postingan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(labelText: 'Judul'),
                validator: (value) => value == null || value.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _isiController,
                decoration: InputDecoration(labelText: 'Isi Postingan'),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Isi tidak boleh kosong' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Posting'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
