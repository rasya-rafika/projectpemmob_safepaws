import 'package:flutter/material.dart';

import 'kontak_model.dart';
import 'services/kontak_service.dart';

class KontakAdminPage extends StatefulWidget {
  const KontakAdminPage({super.key});

  @override
  State<KontakAdminPage> createState() => _KontakAdminPageState();
}

class _KontakAdminPageState extends State<KontakAdminPage> {
  final List<String> _kategoriList = [
    'Semua',
    'Saran',
    'Laporan Masalah',
    'Daftar Dokter Hewan SafePaws',
    'Tambah Hewan Adopsi SafePaws',
  ];
  String _selectedKategori = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan Masuk'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _kategoriList.length,
              itemBuilder: (context, index) {
                final kategori = _kategoriList[index];
                final selected = kategori == _selectedKategori;
                return Padding(
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  child: ChoiceChip(
                    label: Text(kategori),
                    selected: selected,
                    selectedColor: Colors.orange,
                    backgroundColor: Colors.orange.shade100,
                    onSelected: (_) {
                      setState(() => _selectedKategori = kategori);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<KontakPesan>>(
              stream: KontakService().streamPesan(),
              builder: (context, snapshot) {
                final semuaPesan = snapshot.data ?? [];

                final pesanTampil = _selectedKategori == 'Semua'
                    ? semuaPesan
                    : semuaPesan.where((p) => p.kategori == _selectedKategori).toList();

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (pesanTampil.isEmpty) {
                  return const Center(child: Text('Belum ada pesan.'));
                }

                return ListView.builder(
                  itemCount: pesanTampil.length,
                  itemBuilder: (context, index) {
                    final pesan = pesanTampil[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(pesan.judul),
                        subtitle: Text('${pesan.nama} • ${pesan.kontak}'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(pesan.judul),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nama: ${pesan.nama}'),
                                  Text('Kontak: ${pesan.kontak}'),
                                  Text('Kategori: ${pesan.kategori}'),
                                  const SizedBox(height: 8),
                                  Text('Pesan:'),
                                  Text(pesan.deskripsi),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tutup'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
