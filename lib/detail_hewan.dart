import 'package:flutter/material.dart';
import 'adopsi_model.dart';
import 'form_adopsi.dart';

class DetailHewanPage extends StatelessWidget {
  final HewanAdopsi hewan;

  const DetailHewanPage({Key? key, required this.hewan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageWidget = hewan.imageUrl.isNotEmpty
        ? Image.asset(
            hewan.imageUrl,
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          )
        : const Icon(Icons.pets, size: 100, color: Colors.grey);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 60),
          imageWidget,
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          hewan.nama,
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.favorite_border, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        hewan.lokasi,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const Spacer(),
                      const Text('1.4 km away', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoChip('${hewan.umur}', 'Age'),
                      _infoChip('${hewan.jenisKelamin}', 'Sex'),
                      _infoChip('${hewan.beratBadan}', 'Weight'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('About',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    hewan.deskripsi,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormAdopsiPage(hewan: hewan),
                          ),
                        );
                      },
                      icon: const Icon(Icons.pets),
                      label: const Text('Adopsi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _infoChip(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
