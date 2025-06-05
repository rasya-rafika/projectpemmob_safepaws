import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'adopsi_model.dart';
import 'services/adopsi_service.dart';

class TambahAdopsiPage extends StatefulWidget {
  const TambahAdopsiPage({super.key});

  @override
  State<TambahAdopsiPage> createState() => _TambahAdopsiPageState();
}

class _TambahAdopsiPageState extends State<TambahAdopsiPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController umurController = TextEditingController();
  final TextEditingController beratController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  File? _pickedImage;
  String _jenisKelamin = 'Male';
  String _kategori = 'Kucing';
  final List<String> _kategoriList = ['Kucing', 'Anjing', 'Kelinci', 'Burung', 'Lainnya'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('adopsi_images/$fileName.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Gagal upload gambar: $e");
      return null;
    }
  }

  Future<void> _simpanData() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _uploadImage(_pickedImage!);
      }

      final hewan = HewanAdopsi(
        id: '',
        nama: namaController.text.trim(),
        umur: umurController.text.trim(),
        jenisKelamin: _jenisKelamin,
        beratBadan: beratController.text.trim(),
        kategori: _kategori,
        deskripsi: deskripsiController.text.trim(),
        imageUrl: imageUrl ?? '',
        lokasi: _lokasiController.text.trim(),
      );

      await AdopsiService().tambahHewan(hewan);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hewan berhasil ditambahkan untuk adopsi')),
      );

      Navigator.pop(context, {
        'name': hewan.nama,
        'location': hewan.lokasi,
        'image': hewan.imageUrl,
        'category': hewan.kategori,
      });
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    _lokasiController.dispose();
    umurController.dispose();
    beratController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Hewan Adopsi'),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _pickedImage != null
                      ? Image.file(_pickedImage!, fit: BoxFit.cover)
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Klik untuk pilih gambar', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Hewan'),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: umurController,
                decoration: const InputDecoration(labelText: 'Umur'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Jenis Kelamin: "),
                  Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: 'Male',
                          groupValue: _jenisKelamin,
                          onChanged: (value) => setState(() => _jenisKelamin = value!),
                        ),
                        const Text("Jantan"),
                        Radio<String>(
                          value: 'Female',
                          groupValue: _jenisKelamin,
                          onChanged: (value) => setState(() => _jenisKelamin = value!),
                        ),
                        const Text("Betina"),
                      ],
                    ),
                  )
                ],
              ),
              TextFormField(
                controller: beratController,
                decoration: const InputDecoration(labelText: 'Berat Badan'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              DropdownButtonFormField<String>(
                value: _kategori,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: _kategoriList.map((kategori) {
                  return DropdownMenuItem(value: kategori, child: Text(kategori));
                }).toList(),
                onChanged: (value) => setState(() => _kategori = value!),
              ),
              TextFormField(
                controller: deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text("Tambah"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
