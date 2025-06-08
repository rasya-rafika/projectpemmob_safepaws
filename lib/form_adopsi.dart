import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'adopsi_model.dart';
import 'services/form_adopsi_service.dart';
import 'form_adopsi_model.dart';

class FormAdopsiPage extends StatefulWidget {
  final HewanAdopsi hewan;

  const FormAdopsiPage({Key? key, required this.hewan}) : super(key: key);

  @override
  State<FormAdopsiPage> createState() => _FormAdopsiPageState();
}

class _FormAdopsiPageState extends State<FormAdopsiPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usiaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _alasanController = TextEditingController();

  bool _pernah = false;
  bool _bersedia = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _bersedia) {
      final form = FormAdopsi(
        id: const Uuid().v4(),
        namaLengkap: _namaController.text,
        usia: _usiaController.text,
        alamat: _alamatController.text,
        pernahMemelihara: _pernah,
        alasan: _alasanController.text,
        bersedia: _bersedia,
        idHewan: widget.hewan.id,
        namaHewan: widget.hewan.nama,
      );

      try {
        await FormAdopsiService().kirimFormAdopsi(form);
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Form berhasil dikirim!')
                ],
              ),
              content: const Text(
                'Hasil persetujuan adopsi akan segera diberitahukan oleh pemilik hewan. Akan dihubungi melalui kontak yang Anda cantumkan!'
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          _formKey.currentState!.reset();
          setState(() {
            _pernah = false;
            _bersedia = false;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim form: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Adopsi'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap Anda'),
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usiaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Usia Anda (tahun)'),
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              const Text('Pernah memelihara hewan sebelumnya?'),
              RadioListTile(
                title: const Text('Ya'),
                value: true,
                groupValue: _pernah,
                onChanged: (val) => setState(() => _pernah = true),
              ),
              RadioListTile(
                title: const Text('Tidak'),
                value: false,
                groupValue: _pernah,
                onChanged: (val) => setState(() => _pernah = false),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _alasanController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mengapa ingin mengadopsi hewan ini?'),
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _bersedia,
                onChanged: (val) => setState(() => _bersedia = val ?? false),
                title: const Text(
                  'Saya bersedia merawat hewan ini dengan penuh tanggung jawab dan menanggung kebutuhan makannya, kesehatannya, serta vaksinasi',
                ),
              ),
              const SizedBox(height: 20),
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
