import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectpemmob_safepaws/komunitas_model.dart';

class KomunitasService {
  final _postCollection = FirebaseFirestore.instance.collection('posts');

  Future<List<Post>> getAllPosts() async {
    final snapshot = await _postCollection.orderBy('timestamp', descending: true).get();
    return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }

  Future<Post> createPost({
    required String username,
    required String content,
  }) async {
    final newDoc = await _postCollection.add({
      'username': username,
      'content': content,
      'timestamp': Timestamp.now(),
      'likes': 0,
      'likedBy': [],
    });

    final snapshot = await newDoc.get();
    return Post.fromFirestore(snapshot);
  }

  Future<void> likePost(String postId, String userId) async {
    final doc = _postCollection.doc(postId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(doc);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      final alreadyLiked = likedBy.contains(userId);

      if (!alreadyLiked) {
        likedBy.add(userId);
        tx.update(doc, {
          'likedBy': likedBy,
          'likes': FieldValue.increment(1),
        });
      }
    });
  }

  Future<void> unlikePost(String postId, String userId) async {
    final doc = _postCollection.doc(postId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(doc);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
        tx.update(doc, {
          'likedBy': likedBy,
          'likes': FieldValue.increment(-1),
        });
      }
    });
  }

  Future<void> deletePost(String postId) async {
    await _postCollection.doc(postId).delete();
  }

  Future<List<Comment>> getComments(String postId) async {
    final commentsSnapshot = await _postCollection
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp')
        .get();

    return commentsSnapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
  }

  Future<Comment> addComment({
    required String postId,
    required String username,
    required String content,
  }) async {
    final commentRef = await _postCollection
        .doc(postId)
        .collection('comments')
        .add({
      'username': username,
      'content': content,
      'timestamp': Timestamp.now(),
    });

    final snapshot = await commentRef.get();
    return Comment.fromFirestore(snapshot);
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    await _postCollection
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  Future<List<Post>> searchPosts(String keyword) async {
    final snapshot = await _postCollection.get();
    return snapshot.docs.map((doc) => Post.fromFirestore(doc)).where((post) {
      return post.username.toLowerCase().contains(keyword.toLowerCase()) ||
             post.content.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
  }

  Future<List<Post>> getPostsByUser(String username) async {
    final snapshot = await _postCollection
        .where('username', isEqualTo: username)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }
}