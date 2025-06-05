class HewanAdopsi {
  final String id;
  final String nama;
  final String umur;
  final String jenisKelamin;
  final String beratBadan;
  final String kategori;
  final String deskripsi;
  final String imageUrl;
  final String lokasi;

  HewanAdopsi({
    required this.id,
    required this.nama,
    required this.umur,
    required this.jenisKelamin,
    required this.beratBadan,
    required this.kategori,
    required this.deskripsi,
    required this.imageUrl,
    required this.lokasi,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'umur': umur,
      'jenisKelamin': jenisKelamin,
      'beratBadan': beratBadan,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'imageUrl': imageUrl,
      'lokasi': lokasi,
    };
  }

  factory HewanAdopsi.fromMap(String id, Map<String, dynamic> data) {
    return HewanAdopsi(
      id: id,
      nama: data['nama'] ?? '',
      umur: data['umur'] ?? '',
      jenisKelamin: data['jenisKelamin'] ?? '',
      beratBadan: data['beratBadan'] ?? '',
      kategori: data['kategori'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      lokasi: data['lokasi'] ?? '',
    );
  }
}
