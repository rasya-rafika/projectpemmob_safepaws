import 'package:flutter/material.dart';
import 'models.dart';
import 'tambah_adopsi.dart';
import 'adopsi_model.dart';
import 'services/adopsi_service.dart';

class AdopsiPage extends StatefulWidget {
  final UserRole userRole;

  const AdopsiPage({Key? key, required this.userRole}) : super(key: key);

  @override
  State<AdopsiPage> createState() => _AdopsiPageState();
}

class _AdopsiPageState extends State<AdopsiPage> {
  final List<String> _categories = ['Semua', 'Kucing', 'Anjing', 'Burung', 'Kelinci', 'Lainnya'];
  String _selectedCategory = 'Semua';

  final List<HewanAdopsi> _dummyAnimals = [
    HewanAdopsi(
      id: '1',
      nama: 'Pussy',
      umur: '2',
      jenisKelamin: 'Betina',
      beratBadan: '3',
      kategori: 'Kucing',
      deskripsi: 'Manja dan lucu',
      lokasi: 'Mojokerto',
      imageUrl: 'assets/images/pussy.png',
    ),
    HewanAdopsi(
      id: '2',
      nama: 'Kuma',
      umur: '1',
      jenisKelamin: 'Jantan',
      beratBadan: '5',
      kategori: 'Anjing',
      deskripsi: 'Setia dan pintar',
      lokasi: 'Surabaya',
      imageUrl: 'assets/images/kuma.png',
    ),
    HewanAdopsi(
      id: '3',
      nama: 'Jojo',
      umur: '3',
      jenisKelamin: 'Betina',
      beratBadan: '4',
      kategori: 'Kucing',
      deskripsi: 'Tenang dan bersih',
      lokasi: 'Sidoarjo',
      imageUrl: 'assets/images/jojo.png',
    ),
    HewanAdopsi(
      id: '4',
      nama: 'Rocky',
      umur: '4',
      jenisKelamin: 'Jantan',
      beratBadan: '6',
      kategori: 'Anjing',
      deskripsi: 'Ceria dan aktif',
      lokasi: 'Lamongan',
      imageUrl: 'assets/images/rocky.png',
    ),
    HewanAdopsi(
      id: '5',
      nama: 'Willow',
      umur: '1.5',
      jenisKelamin: 'Betina',
      beratBadan: '2',
      kategori: 'Anjing',
      deskripsi: 'Pemalu tapi manis',
      lokasi: 'Kediri',
      imageUrl: 'assets/images/willow.png',
    ),
    HewanAdopsi(
      id: '6',
      nama: 'Ozzy',
      umur: '2',
      jenisKelamin: 'Jantan',
      beratBadan: '3',
      kategori: 'Kucing',
      deskripsi: 'Suka tidur di pangkuan',
      lokasi: 'Bali',
      imageUrl: 'assets/images/ozzy.png',
    ),
  ];

  void _konfirmasiHapus(HewanAdopsi animal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Hewan'),
        content: Text('Yakin ingin menghapus ${animal.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AdopsiService().deleteHewan(animal.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole == UserRole.admin;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: const [
                  Icon(Icons.pets, color: Colors.deepOrange),
                  SizedBox(width: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: 'Adopt\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange)),
                        TextSpan(
                            text: 'Hewan favoritmu',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (isAdmin)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TambahAdopsiPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.deepOrange,
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),

              const SizedBox(height: 8),
              const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: Colors.orange,
                        backgroundColor: Colors.orange.shade100,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: StreamBuilder<List<HewanAdopsi>>(
                  stream: AdopsiService().streamHewanAdopsi(),
                  builder: (context, snapshot) {
                    final firebaseAnimals = snapshot.data ?? [];
                    final combined = [..._dummyAnimals, ...firebaseAnimals];

                    final filteredAnimals = _selectedCategory == 'Semua'
                        ? combined
                        : combined.where((a) => a.kategori == _selectedCategory).toList();

                    if (snapshot.connectionState == ConnectionState.waiting && firebaseAnimals.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (filteredAnimals.isEmpty) {
                      return const Center(child: Text('Belum ada hewan di kategori ini.'));
                    }

                    return GridView.builder(
                      itemCount: filteredAnimals.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final animal = filteredAnimals[index];
                        final isFirebaseData = !_dummyAnimals.any((d) => d.id == animal.id);

                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: animal.imageUrl.isEmpty
                                          ? const Center(
                                              child: Icon(Icons.pets, size: 40, color: Colors.white),
                                            )
                                          : Image.asset(
                                              animal.imageUrl,
                                              fit: BoxFit.contain,
                                              width: double.infinity,
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(animal.nama,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        Text(animal.lokasi,
                                            style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Icon(Icons.favorite_border, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isAdmin && isFirebaseData)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TambahAdopsiPage(hewanEdit: animal),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                                      onPressed: () {
                                        _konfirmasiHapus(animal);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
