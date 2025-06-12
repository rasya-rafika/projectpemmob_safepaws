class Post {
  final String id;
  final String username;
  final String content;
  final DateTime timestamp;
  final List<Comment> comments;
  int likes;

  Post({
    required this.id,
    required this.username,
    required this.content,
    required this.timestamp,
    required this.comments,
    this.likes = 0,
  });
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
}