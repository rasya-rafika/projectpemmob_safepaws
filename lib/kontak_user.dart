import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'services/kontak_service.dart';
import 'kontak_model.dart';

class FormKontakPage extends StatefulWidget {
  const FormKontakPage({super.key});

  @override
  State<FormKontakPage> createState() => _FormKontakPageState();
}

class _FormKontakPageState extends State<FormKontakPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kontakController = TextEditingController();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();

  final List<String> _kategoriList = [
    'Saran',
    'Laporan Masalah',
    'Daftar Dokter Hewan SafePaws',
    'Tambah Hewan Adopsi SafePaws'
  ];
  String? _selectedKategori;

  @override
  void dispose() {
    _namaController.dispose();
    _kontakController.dispose();
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedKategori != null) {
      final pesan = KontakPesan(
        id: const Uuid().v4(),
        nama: _namaController.text,
        kontak: _kontakController.text,
        kategori: _selectedKategori!,
        judul: _judulController.text,
        deskripsi: _deskripsiController.text,
      );

      try {
        await KontakService().kirimPesan(pesan);
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Pesan berhasil dikirim!'),
              content: const Text('Kami akan menindaklanjuti pesan Anda secepatnya.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                )
              ],
            ),
          );
          _formKey.currentState!.reset();
          setState(() => _selectedKategori = null);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Contact'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kontakController,
                decoration: const InputDecoration(labelText: 'Email / No. WhatsApp'),
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Kategori Pesan'),
                value: _selectedKategori,
                items: _kategoriList
                    .map((kat) => DropdownMenuItem(value: kat, child: Text(kat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedKategori = val),
                validator: (val) => val == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul Pesan'),
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi Pesan'),
                maxLines: 4,
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
