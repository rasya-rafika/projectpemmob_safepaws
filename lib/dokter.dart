import 'package:flutter/material.dart';

import 'dokter_model.dart'; // Import kelas Dokter dari sini
import 'login.dart';
import 'models.dart'; // Hanya untuk UserRole
import 'services/dokter_service.dart';

class DokterPage extends StatefulWidget {
  final UserRole userRole;

  const DokterPage({super.key, required this.userRole});

  @override
  State<DokterPage> createState() => _DokterPageState();
}

class _DokterPageState extends State<DokterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _pengalamanController = TextEditingController();
  final _lokasiController = TextEditingController();
  String? _currentDoctorId;
  bool _isEditing = false;

  @override
  void dispose() {
    _namaController.dispose();
    _pengalamanController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _namaController.clear();
    _pengalamanController.clear();
    _lokasiController.clear();
    _currentDoctorId = null;
    _isEditing = false;
  }

  void _showAddEditDoctorDialog({Dokter? dokter}) {
    if (dokter != null) {
      _namaController.text = dokter.nama;
      _pengalamanController.text = dokter.pengalaman;
      _lokasiController.text = dokter.lokasi;
      _currentDoctorId = dokter.id;
      _isEditing = true;
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isEditing ? 'Edit Dokter' : 'Tambah Dokter'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Nama dokter wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pengalamanController,
                  decoration: const InputDecoration(
                    labelText: 'Pengalaman',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Pengalaman wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lokasiController,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi Praktik',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Lokasi wajib diisi' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearForm();
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final newDokter = Dokter(
                  id: _currentDoctorId ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  nama: _namaController.text,
                  pengalaman: _pengalamanController.text,
                  lokasi: _lokasiController.text,
                );
                if (_isEditing) {
                  await DokterService().updateDokter(newDokter);
                } else {
                  await DokterService().addDokter(newDokter);
                }
                Navigator.of(context).pop();
                _clearForm();
              }
            },
            child: Text(_isEditing ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDoctor(Dokter dokter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Dokter'),
        content: Text('Apakah Anda yakin ingin menghapus dokter ${dokter.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DokterService().deleteDokter(dokter.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showDoctorDetails(Dokter dokter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dokter.nama),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text('Pengalaman: ${dokter.pengalaman}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text('Lokasi: ${dokter.lokasi}')),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokter Hewan', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFA0451B),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFF6600),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Login sebagai: ${isAdmin ? 'Admin' : 'User Biasa'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Dokter>>(
              stream: DokterService().getDokterList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final dokterList = snapshot.data ?? [];

                if (dokterList.isEmpty) {
                  return const Center(child: Text('Belum ada data dokter.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dokterList.length,
                  itemBuilder: (context, index) {
                    final dokter = dokterList[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(dokter.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('Pengalaman: ${dokter.pengalaman}'),
                            Text('Lokasi: ${dokter.lokasi}'),
                          ],
                        ),
                        onTap: () => _showDoctorDetails(dokter),
                        trailing: isAdmin
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showAddEditDoctorDialog(dokter: dokter),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDeleteDoctor(dokter),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddEditDoctorDialog(),
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}