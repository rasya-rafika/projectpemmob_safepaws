import 'package:flutter/material.dart';

import 'komunitas_model.dart';

class KomunitasCard extends StatelessWidget {
  final Community komunitas;
  final bool isJoined;

  const KomunitasCard({
    Key? key,
    required this.komunitas,
    required this.isJoined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(komunitas.name),
        subtitle: Text(komunitas.description),
        trailing: isJoined
            ? const Text(
                "Joined",
                style: TextStyle(color: Colors.green),
              )
            : const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigasi ke detail komunitas jika perlu
        },
      ),
    );
  }
}