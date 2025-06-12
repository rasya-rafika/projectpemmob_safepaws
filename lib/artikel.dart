import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'artikel_model.dart';
import 'services/artikel_service.dart';
import 'user_model.dart';

class ArtikelPage extends StatefulWidget {
  final UserRole userRole;
  const ArtikelPage({super.key, required this.userRole});

  @override
  State<ArtikelPage> createState() => _ArtikelPageState();
}

class _ArtikelPageState extends State<ArtikelPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _linkController = TextEditingController();
  final _deskripsiController = TextEditingController();

  Future<void> _submitArtikel() async {
    if (_formKey.currentState!.validate()) {
      final artikel = Artikel(
        id: const Uuid().v4(),
        judul: _judulController.text,
        link: _linkController.text,
        deskripsi: _deskripsiController.text,
      );
      try {
        await ArtikelService().tambahArtikel(artikel);
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('ARTIKEL BERHASIL TERKIRIM!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                )
              ],
            ),
          );
          _formKey.currentState!.reset();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal kirim artikel: $e')),
        );
      }
    }
  }

  Future<void> _bukaLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka link.')),
      );
    }
  }

  Future<void> _konfirmasiHapus(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Artikel'),
        content: const Text('Yakin ingin menghapus artikel ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      await ArtikelService().hapusArtikel(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel'),
        backgroundColor: Colors.orange.shade800,
      ),
      body: StreamBuilder<List<Artikel>>(
        stream: ArtikelService().ambilArtikelStream(),
        builder: (context, snapshot) {
          final artikelList = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isAdmin) ...[
                  const Text(
                    'Bagikan Pengetahuan Mengenai Hewan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _judulController,
                          decoration: const InputDecoration(labelText: 'Judul Artikel'),
                          validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _linkController,
                          decoration: const InputDecoration(labelText: 'Link Artikel (URL)'),
                          validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _deskripsiController,
                          decoration: const InputDecoration(labelText: 'Deskripsi'),
                          maxLines: 3,
                          validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _submitArtikel,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          child: const Text('Submit Artikel'),
                        )
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                ],
                const Text(
                  'Daftar Artikel yang Tersimpan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator()),
                if (artikelList.isEmpty)
                  const Center(child: Text('Belum ada artikel.')),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: artikelList.length,
                  itemBuilder: (context, index) {
                    final artikel = artikelList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(artikel.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(artikel.deskripsi),
                        trailing: isAdmin
                            ? IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _konfirmasiHapus(artikel.id),
                              )
                            : null,
                        onTap: () => _bukaLink(artikel.link),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
