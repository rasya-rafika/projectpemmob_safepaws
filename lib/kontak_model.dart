class KontakPesan {
  final String id;
  final String nama;
  final String kontak;
  final String kategori;
  final String judul;
  final String deskripsi;

  KontakPesan({
    required this.id,
    required this.nama,
    required this.kontak,
    required this.kategori,
    required this.judul,
    required this.deskripsi,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'kontak': kontak,
      'kategori': kategori,
      'judul': judul,
      'deskripsi': deskripsi,
    };
  }

  factory KontakPesan.fromMap(String id, Map<String, dynamic> map) {
    return KontakPesan(
      id: id,
      nama: map['nama'] ?? '',
      kontak: map['kontak'] ?? '',
      kategori: map['kategori'] ?? '',
      judul: map['judul'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
    );
  }
}
