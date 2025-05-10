import 'package:flutter/material.dart';
import 'models.dart' as model;
import 'login.dart';

// Dokter class
class Dokter {
  String id;
  String nama;
  String pengalaman;
  String lokasi;

  Dokter({
    required this.id,
    required this.nama,
    required this.pengalaman,
    required this.lokasi,
  });
}

class DokterPage extends StatefulWidget {
  final model.UserRole userRole;

  const DokterPage({Key? key, required this.userRole}) : super(key: key);

  @override
  _DokterPageState createState() => _DokterPageState();
}

class _DokterPageState extends State<DokterPage> {
  List<Dokter> _dokterList = [
    Dokter(
      id: '1',
      nama: 'dr. Anita Wati',
      pengalaman: '5 tahun',
      lokasi: 'Klinik Hewan Sehat, Jakarta Selatan',
    ),
    Dokter(
      id: '2',
      nama: 'drh. Budi Santoso, Sp.KH',
      pengalaman: '8 tahun',
      lokasi: 'Rumah Sakit Hewan Cinta Satwa, Bandung',
    ),
  ];

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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama dokter wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pengalamanController,
                  decoration: const InputDecoration(
                    labelText: 'Pengalaman',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pengalaman dokter wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lokasiController,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi Praktik',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lokasi praktik wajib diisi';
                    }
                    return null;
                  },
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_isEditing) {
                  setState(() {
                    final index = _dokterList.indexWhere((d) => d.id == _currentDoctorId);
                    if (index != -1) {
                      _dokterList[index] = Dokter(
                        id: _currentDoctorId!,
                        nama: _namaController.text,
                        pengalaman: _pengalamanController.text,
                        lokasi: _lokasiController.text,
                      );
                    }
                  });
                } else {
                  setState(() {
                    _dokterList.add(
                      Dokter(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        nama: _namaController.text,
                        pengalaman: _pengalamanController.text,
                        lokasi: _lokasiController.text,
                      ),
                    );
                  });
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
            onPressed: () {
              setState(() {
                _dokterList.removeWhere((d) => d.id == dokter.id);
              });
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
    final isAdmin = widget.userRole == model.UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokter Hewan'),
        backgroundColor: Colors.blue,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade100,
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Login sebagai: ${isAdmin ? 'Admin' : 'User Biasa'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _dokterList.length,
              itemBuilder: (context, index) {
                final dokter = _dokterList[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      dokter.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(dokter.pengalaman),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.red),
                            const SizedBox(width: 4),
                            Expanded(child: Text(dokter.lokasi)),
                          ],
                        ),
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
                        : const Icon(Icons.arrow_forward_ios),
                  ),
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