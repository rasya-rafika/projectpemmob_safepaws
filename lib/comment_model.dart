import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final String communityId;
  final List<String> likes;
  final Timestamp createdAt;

  Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.communityId,
    required this.likes,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      content: data['content'] ?? '',
      communityId: data['communityId'] ?? '',
      likes: List<String>.from(data['likes'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}