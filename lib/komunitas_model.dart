import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String username;
  final String content;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy;

  Post({
    required this.id,
    required this.username,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.likedBy = const [],
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      username: data['username'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'likedBy': likedBy,
    };
  }
}

class Comment {
  final String id;
  final String username;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.username,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      username: data['username'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}