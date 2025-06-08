class FormAdopsi {
  final String id;
  final String namaLengkap;
  final String usia;
  final String alamat;
  final bool pernahMemelihara;
  final String alasan;
  final bool bersedia;
  final String idHewan;
  final String namaHewan;

  FormAdopsi({
    required this.id,
    required this.namaLengkap,
    required this.usia,
    required this.alamat,
    required this.pernahMemelihara,
    required this.alasan,
    required this.bersedia,
    required this.idHewan,
    required this.namaHewan,
  });

  Map<String, dynamic> toMap() => {
        'namaLengkap': namaLengkap,
        'usia': usia,
        'alamat': alamat,
        'pernahMemelihara': pernahMemelihara,
        'alasan': alasan,
        'bersedia': bersedia,
        'idHewan': idHewan,
        'namaHewan': namaHewan,
      };

  factory FormAdopsi.fromMap(String id, Map<String, dynamic> data) {
    return FormAdopsi(
      id: id,
      namaLengkap: data['namaLengkap'] ?? '',
      usia: data['usia'] ?? '',
      alamat: data['alamat'] ?? '',
      pernahMemelihara: data['pernahMemelihara'] ?? false,
      alasan: data['alasan'] ?? '',
      bersedia: data['bersedia'] ?? false,
      idHewan: data['idHewan'] ?? '',
      namaHewan: data['namaHewan'] ?? '',
    );
  }
}