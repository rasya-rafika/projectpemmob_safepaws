class Artikel {
  final String id;
  final String judul;
  final String link;
  final String deskripsi;

  Artikel({
    required this.id,
    required this.judul,
    required this.link,
    required this.deskripsi,
  });

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'link': link,
      'deskripsi': deskripsi,
    };
  }

  factory Artikel.fromMap(String id, Map<String, dynamic> map) {
    return Artikel(
      id: id,
      judul: map['judul'] ?? '',
      link: map['link'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
    );
  }
}