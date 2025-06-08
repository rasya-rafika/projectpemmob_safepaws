import 'package:cloud_firestore/cloud_firestore.dart';

class Community{
  final String id;
  final String name;
  final String description;
  final String adminId;
  final List<String> members;
  final Timestamp createdAt;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.members,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'adminId': adminId,
      'members': members,
      'createdAt': createdAt,
    };
  }
  
  factory Community.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Community(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      adminId: data['adminId'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
