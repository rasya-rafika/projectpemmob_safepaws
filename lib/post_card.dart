import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String currentUserId;

  const PostCard({
    Key? key,
    required this.post,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLiked = post.likes.contains(currentUserId);
    final String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(post.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Text(
                    post.authorName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content
            Text(post.content),
            const SizedBox(height: 12),
            // Footer (Like)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text('${post.likes.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
