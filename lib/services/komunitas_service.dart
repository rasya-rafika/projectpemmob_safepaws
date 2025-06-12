import 'package:projectpemmob_safepaws/komunitas_model.dart';

class KomunitasService {
  static final KomunitasService _instance = KomunitasService._internal();
  factory KomunitasService() => _instance;
  KomunitasService._internal();

  final List<Post> _posts = [
    Post(
      id: "1",
      username: "davinakaramoy",
      content: "cara biar kitten mau diem dikit/tenang itu gimana ya guys? soalnya baru undang, kalo dikasih air, sampai selang gokha ya juga gokha sampai pegel selang tani ngeline kelas selang tani.",
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      comments: [
        Comment(
          id: "1",
          username: "rayyasum_4d",
          content: "kalau balik ciku juga udah kurang kenyang aku kejitu dan takut gabisa yeng jago aku makan kuncinya aww apa tauning aku ngetime makin udah katanya mau",
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Comment(
          id: "2",
          username: "anrnovekidsrln_2d",
          content: "siMiGA gimana ya biar gak ngafeng mau potdimiu udah abisgek makar. dan kalo aja digi haju blau jain dapet apa harus pake sama cairan",
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        )
      ],
      likes: 16,
    ),
  ];

  Future<Post> createPost({required String username, required String content}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      content: content,
      timestamp: DateTime.now(),
      comments: [],
      likes: 0,
    );
    _posts.insert(0, newPost);
    return newPost;
  }

  Future<List<Post>> getAllPosts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_posts);
  }
  Future<Post?> getPostById(String id) async {
    await Future.delayed(Duration(milliseconds: 200));
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> likePost(String postId) async {
    await Future.delayed(Duration(milliseconds: 200));
    try {
      final post = _posts.firstWhere((post) => post.id == postId);
      post.likes++;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unlikePost(String postId) async {
    await Future.delayed(Duration(milliseconds: 200));
    try {
      final post = _posts.firstWhere((post) => post.id == postId);
      if (post.likes > 0) post.likes--;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      _posts.removeWhere((post) => post.id == postId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Comment> addComment({required String postId, required String username, required String content}) async {
    await Future.delayed(Duration(milliseconds: 400));
    final post = _posts.firstWhere((post) => post.id == postId);
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      content: content,
      timestamp: DateTime.now(),
    );
    post.comments.add(newComment);
    return newComment;
  }

  Future<List<Comment>> getCommentsByPostId(String postId) async {
    await Future.delayed(Duration(milliseconds: 200));
    try {
      final post = _posts.firstWhere((post) => post.id == postId);
      return List.from(post.comments);
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteComment(String postId, String commentId) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      final post = _posts.firstWhere((post) => post.id == postId);
      post.comments.removeWhere((comment) => comment.id == commentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Post>> searchPosts(String keyword) async {
    await Future.delayed(Duration(milliseconds: 400));
    return _posts.where((post) {
      return post.content.toLowerCase().contains(keyword.toLowerCase()) ||
             post.username.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
  }

  Future<List<Post>> getPostsByUser(String username) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _posts.where((post) => post.username == username).toList();
  }

  Future<List<Post>> refreshPosts() async {
    await Future.delayed(Duration(seconds: 1));
    return List.from(_posts);
  }
}