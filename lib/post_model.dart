import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final String communityId;
  final List<String> likes;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.communityId,
    required this.likes,
    required this.createdAt,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      content: data['content'] ?? '',
      communityId: data['communityId'] ?? '',
      likes: List<String>.from(data['likes'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'communityId': communityId,
      'likes': likes,
      'createdAt': createdAt,
    };
  }
}
