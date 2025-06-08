import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectpemmob_safepaws/comment_model.dart';
import 'package:projectpemmob_safepaws/komunitas_model.dart';


class KomunitasService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // ✅ Get all communities (Explore)
  Stream<List<Community>> getAllKomunitas() {
    return _firestore
        .collection('communities')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>   Community.fromFirestore(doc))
            .toList());
  }

  // ✅ Get communities the user joined
  Stream<List<Community>> getMyKomunitas() {
    return _firestore
        .collection('communities')
        .where('members', arrayContains: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Community.fromFirestore(doc))
            .toList());
  }

  // ✅ Check if user is a member
  Future<bool> isMember(String komunitasId) async {
    final doc = await _firestore.collection('communities').doc(komunitasId).get();
    if (doc.exists) {
      final members = List<String>.from(doc.data()!['members'] ?? []);
      return members.contains(currentUserId);
    }
    return false;
  }

  // ✅ Join community
  Future<void> joinCommunity(String komunitasId) async {
    await _firestore.collection('communities').doc(komunitasId).update({
      'members': FieldValue.arrayUnion([currentUserId])
    });
  }

  // ✅ Leave community
  Future<void> leaveCommunity(String komunitasId) async {
    await _firestore.collection('communities').doc(komunitasId).update({
      'members': FieldValue.arrayRemove([currentUserId])
    });
  }

  // ✅ Get posts in a community
  Stream<List<Comment>> getCommunityPosts(String communityId) {
    return _firestore
        .collection('posts')
        .where('communityId', isEqualTo: communityId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromFirestore(doc))
            .toList());
  }

  // ✅ Add new post
  Future<void> addPost({
    required String communityId,
    required String content,
    required String authorName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('posts').add({
      'authorId': user.uid,
      'authorName': authorName,
      'content': content,
      'communityId': communityId,
      'likes': [],
      'createdAt': Timestamp.now(),
    });
  }

  // ✅ Like / Unlike post
  Future<void> toggleLikePost(String postId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final doc = await postRef.get();

    if (!doc.exists) return;

    final likes = List<String>.from(doc['likes'] ?? []);
    if (likes.contains(currentUserId)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([currentUserId])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([currentUserId])
      });
    }
  }
}