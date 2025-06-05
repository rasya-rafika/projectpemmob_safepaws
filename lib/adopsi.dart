import 'package:flutter/material.dart';
import 'login.dart';
import 'models.dart'; // Hanya untuk UserRole
import 'tambah_adopsi.dart';

class AdopsiPage extends StatefulWidget {
  const AdopsiPage({Key? key}) : super(key: key);

  @override
  State<AdopsiPage> createState() => _AdopsiPageState();
}

class _AdopsiPageState extends State<AdopsiPage> {
  final List<Map<String, String>> _allAnimals = [
    {'name': 'Pussy', 'location': 'Mojokerto', 'image': 'assets/images/pussy.png', 'category': 'Kucing'},
    {'name': 'Kuma', 'location': 'Surabaya', 'image': 'assets/images/kuma.png', 'category': 'Anjing'},
    {'name': 'Jojo', 'location': 'Sidoarjo', 'image': 'assets/images/jojo.png', 'category': 'Kucing'},
    {'name': 'Rocky', 'location': 'Lamongan', 'image': 'assets/images/rocky.png', 'category': 'Anjing'},
    {'name': 'Willow', 'location': 'Kediri', 'image': 'assets/images/willow.png', 'category': 'Anjing'},
    {'name': 'Ozzy', 'location': 'Bali', 'image': 'assets/images/ozzy.png', 'category': 'Kucing'},
  ];

  final List<String> _categories = ['Semua', 'Kucing', 'Anjing', 'Burung', 'Kelinci', 'Lainnya'];
  String _selectedCategory = 'Semua';

  List<Map<String, String>> get _filteredAnimals {
    if (_selectedCategory == 'Semua') return _allAnimals;
    return _allAnimals.where((animal) => animal['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
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

              // Search bar dan tombol tambah
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari hewan adopsi',
                        filled: true,
                        fillColor: Colors.orange.shade50,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final newPet = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TambahAdopsiPage()),
                      );

                      if (newPet != null && mounted) {
                        setState(() {
                          _allAnimals.add({
                            'name': newPet['name'],
                            'location': newPet['location'],
                            'image': newPet['image'],
                            'category': newPet['category'],
                          });
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.deepOrange,
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Categories
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

              // Grid Hewan
              Expanded(
                child: GridView.builder(
                  itemCount: _filteredAnimals.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final animal = _filteredAnimals[index];
                    return Container(
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
                              child: animal['image']!.startsWith('http')
                                  ? Image.network(
                                      animal['image']!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image_not_supported),
                                    )
                                  : Image.asset(
                                      animal['image']!,
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
                                Text(animal['name'] ?? '',
                                    style: const TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold)),
                                Text(animal['location'] ?? '',
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
