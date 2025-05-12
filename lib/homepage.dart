import 'package:flutter/material.dart';
import 'dokter.dart';
import 'login.dart';
import 'models.dart';


class HomePage extends StatelessWidget {
  final UserRole userRole;

  const HomePage({Key? key, required this.userRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orange = Color(0xFFFF6F00);
    final darkOrange = Color(0xFF8B3A00);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: orange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Cari dokter terbaik disini',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Coin Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: darkOrange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Petsave', style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 4),
                          Text(
                            '200 koin',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: const [
                          Icon(Icons.add_circle_outline, color: Colors.white),
                          SizedBox(width: 16),
                          Icon(Icons.history, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Fitur Grid
                // Fitur Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildFiturItem(
                      context,
                      title: 'Dokter Hewan',
                      imagePath: 'assets/images/ic_dokter.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DokterPage(userRole: userRole),
                          ),
                        );
                      },
                    ),
                    _buildFiturItem(
                      context,
                      title: 'Adopsi',
                      imagePath: 'assets/images/ic_shelter.png', // <- SUDAH BENAR
                    ),
                    _buildFiturItem(
                      context,
                      title: 'Komunitas',
                      imagePath: 'assets/images/ic_komunitas.png',
                    ),
                    _buildFiturItem(
                      context,
                      title: 'Kontak',
                      imagePath: 'assets/images/ic_kontak.png',
                    ),
                  ],
                ),


                const SizedBox(height: 24),

                // Artikel Hewan Button
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Artikel Hewan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gambar Artikel
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildArtikelCard('assets/images/artikel1.jpg'),
                      _buildArtikelCard('assets/images/artikel2.jpg'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFiturItem(
  BuildContext context, {
  required String title,
  String? imagePath,
  Widget? iconWidget,
  VoidCallback? onTap,
}) {
  final imageContent = iconWidget ??
      (imagePath != null
          ? Image.asset(imagePath, width: 80, height: 80)
          : const Icon(Icons.help_outline, size: 60, color: Colors.grey));

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imageContent,
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}




  Widget _buildArtikelCard(String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(imagePath, width: 180, height: 120, fit: BoxFit.cover),
      ),
    );
  }
}