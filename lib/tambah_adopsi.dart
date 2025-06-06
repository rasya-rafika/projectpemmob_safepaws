import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'adopsi_model.dart';
import 'services/adopsi_service.dart';

class TambahAdopsiPage extends StatefulWidget {
  final HewanAdopsi? hewanEdit;

  const TambahAdopsiPage({Key? key, this.hewanEdit}) : super(key: key);

  @override
  State<TambahAdopsiPage> createState() => _TambahAdopsiPageState();
}

class _TambahAdopsiPageState extends State<TambahAdopsiPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _umurController = TextEditingController();
  final _beratController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String? _selectedGender;
  String? _selectedKategori;
  final List<String> _kategoriList = ['Kucing', 'Anjing', 'Burung', 'Kelinci', 'Lainnya'];
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    final hewan = widget.hewanEdit;
    _isEditing = hewan != null;

    if (_isEditing) {
      _namaController.text = hewan!.nama;
      _umurController.text = hewan.umur;
      _beratController.text = hewan.beratBadan;
      _lokasiController.text = hewan.lokasi;
      _deskripsiController.text = hewan.deskripsi;
      _selectedGender = hewan.jenisKelamin;
      _selectedKategori = hewan.kategori;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _umurController.dispose();
    _beratController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedGender != null && _selectedKategori != null) {
      final hewan = HewanAdopsi(
        id: _isEditing ? widget.hewanEdit!.id : Uuid().v4(),
        nama: _namaController.text,
        umur: _umurController.text,
        jenisKelamin: _selectedGender!,
        beratBadan: _beratController.text,
        kategori: _selectedKategori!,
        deskripsi: _deskripsiController.text,
        lokasi: _lokasiController.text,
        imageUrl: _isEditing ? widget.hewanEdit!.imageUrl : '', // simpan kembali jika sudah ada
      );

      try {
        if (_isEditing) {
          await AdopsiService().updateHewan(hewan);
        } else {
          await AdopsiService().tambahHewan(hewan);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Hewan Adopsi' : 'Tambah Hewan Adopsi';
    final buttonText = _isEditing ? 'Simpan' : 'Tambah';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Hewan'),
                validator: (val) => val == null || val.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator: (val) => val == null || val.isEmpty ? 'Lokasi wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _umurController,
                decoration: const InputDecoration(labelText: 'Umur'),
                validator: (val) => val == null || val.isEmpty ? 'Umur wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              const Text('Jenis Kelamin:'),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Jantan'),
                      value: 'Jantan',
                      groupValue: _selectedGender,
                      onChanged: (val) => setState(() => _selectedGender = val),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Betina'),
                      value: 'Betina',
                      groupValue: _selectedGender,
                      onChanged: (val) => setState(() => _selectedGender = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _beratController,
                decoration: const InputDecoration(labelText: 'Berat Badan'),
                validator: (val) => val == null || val.isEmpty ? 'Berat wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                items: _kategoriList.map((kategori) {
                  return DropdownMenuItem(value: kategori, child: Text(kategori));
                }).toList(),
                onChanged: (val) => setState(() => _selectedKategori = val),
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (val) => val == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: Text(buttonText),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
