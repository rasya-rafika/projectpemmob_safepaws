import 'package:flutter/material.dart';

import 'komunitas_model.dart';
import 'user_model.dart';

class KomunitasPage extends StatefulWidget {
  final UserRole userRole;

  const KomunitasPage({Key? key, required this.userRole}) : super(key: key);

  @override
  State<KomunitasPage> createState() => _KomunitasPageState();
}

class _KomunitasPageState extends State<KomunitasPage> {
  final TextEditingController _postController = TextEditingController();
  final String currentUser = "kamu";
  
  List<Post> posts = [];
  bool isLoading = true;
  bool isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    // Simulate loading
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      posts = [
        Post(
          id: "1",
          username: "davinakaramoy",
          content: "cara biar kitten mau diem dikit/tenang itu gimana ya guys?",
          timestamp: DateTime.now().subtract(Duration(hours: 4)),
          comments: [
            Comment(
              id: "1",
              username: "rayyasum_4d",
              content: "kalau balik ciku juga udah kurang kenyang...",
              timestamp: DateTime.now().subtract(Duration(hours: 3)),
            )
          ],
          likes: 16,
        ),
      ];
      isLoading = false;
    });
  }

  Future<void> _handleAddPost() async {
    if (_postController.text.trim().isEmpty) return;
    
    setState(() => isPosting = true);

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    setState(() {
      posts.insert(0, Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: currentUser,
        content: _postController.text.trim(),
        timestamp: DateTime.now(),
        comments: [],
        likes: 0,
      ));
      isPosting = false;
    });
    
    _postController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Komunitas Pecinta Hewan"),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              child: Text(post.username[0]),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post.username),
                                Text(
                                  "${post.timestamp.hour}:${post.timestamp.minute}",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(post.content),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.favorite_border),
                              onPressed: () {
                                setState(() {
                                  post.likes++;
                                });
                              },
                            ),
                            Text("${post.likes}"),
                            SizedBox(width: 20),
                            IconButton(
                              icon: Icon(Icons.comment),
                              onPressed: () {
                                // Implement comment functionality
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _postController,
                    decoration: InputDecoration(
                      hintText: "Apa yang ingin Anda bagikan?",
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isPosting ? null : _handleAddPost,
                    child: isPosting 
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Posting"),
                  ),
                ],
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
