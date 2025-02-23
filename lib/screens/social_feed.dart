import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SocialFeedScreen extends StatefulWidget {
  @override
  _SocialFeedScreenState createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final TextEditingController _postController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to Add Post to Firestore
  void _addPost() async {
    String postText = _postController.text.trim();
    if (postText.isNotEmpty) {
      await _firestore.collection('posts').add({
        'text': postText,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [], // List of user IDs who liked the post
        'comments': [], // List of comment objects {userId, comment}
      });
      _postController.clear();
    }
  }

  // Function to Like a Post
  void _toggleLike(String postId, List likes, String userId) async {
    if (likes.contains(userId)) {
      likes.remove(userId); // Unlike the post
    } else {
      likes.add(userId); // Like the post
    }
    await _firestore.collection('posts').doc(postId).update({'likes': likes});
  }

  // Function to Add a Comment
  void _addComment(String postId, String userId, String commentText) async {
    if (commentText.trim().isNotEmpty) {
      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([
          {'userId': userId, 'comment': commentText}
        ])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = "user_123"; // Change this to dynamic user ID

    return Scaffold(
      appBar: AppBar(title: Text("Social Feed")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: InputDecoration(
                      hintText: "Write a post...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _addPost,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    List likes = post['likes'];
                    List comments = post['comments'];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(post['text']),
                            subtitle: Text(post['timestamp'] != null
                                ? post['timestamp'].toDate().toString()
                                : "Just now"),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: Icon(
                                  likes.contains(userId)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: likes.contains(userId)
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () =>
                                    _toggleLike(post.id, likes, userId),
                              ),
                              Text("${likes.length} Likes"),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(Icons.comment),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => _commentSection(
                                        post.id, comments, userId),
                                  );
                                },
                              ),
                              Text("${comments.length} Comments"),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Comment Section Modal
  Widget _commentSection(String postId, List comments, String userId) {
    TextEditingController commentController = TextEditingController();
    return Container(
      padding: EdgeInsets.all(10),
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: comments
                  .map((c) => ListTile(
                        title: Text(c['comment']),
                        subtitle: Text("User: ${c['userId']}"),
                      ))
                  .toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(hintText: "Add a comment..."),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  _addComment(postId, userId, commentController.text);
                  commentController.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
