import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coachyp/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post {
  final String id;
  final String coachId;
  final String description;
  final String imageUrl;
  final DateTime timestamp;
  final Map<String, List<String>> availableDates;
  final String username;
  final String type;
  final String profileImgUrl;
  final bool isActive;

  Post({
    required this.id,
    required this.coachId,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    required this.availableDates,
    required this.username,
    required this.type,
    required this.profileImgUrl,
    required this.isActive,
  });
}

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Post> posts = []; // List to store posts
  bool isLoading = true; // Add a loading state flag

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }

  // Fetch user's posts from Firestore
  Future<void> _fetchUserPosts() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print("No user is logged in.");
        setState(() {
          isLoading = false; // Stop loading if no user is logged in
        });
        return; // Exit early if the user is not logged in
      }

      final userId = user.uid;
      print("Fetching posts for user ID: $userId");

      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('coachId', isEqualTo: userId)
          .get();

      // Check if posts are fetched
      print("Fetched posts count: ${querySnapshot.docs.length}");

      final fetchedPosts = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final availableDatesData = data['availableDates'] ?? {}; // Default to an empty map if null

        // Ensure availableDates is a Map<String, List<String>>
        final availableDates = Map<String, List<String>>.from(
          availableDatesData.map((key, value) => MapEntry(key, List<String>.from(value))),
        );

        return Post(
          id: doc.id,
          coachId: data['coachId'],
          description: data['description'],
          imageUrl: data['imageUrl'] ?? '',
          timestamp: data['timestamp'].toDate(),
          availableDates: availableDates,
          username: data['username'] ?? '',
          type: data['type'] ?? '',
          profileImgUrl: data['profileImgUrl'] ?? '',
          isActive: data['isActive'] ?? true, // Set default to true if missing
        );
      }).toList();

      setState(() {
        posts = fetchedPosts;
        isLoading = false; // Set loading state to false once data is fetched
      });
    } catch (e) {
      print("Error fetching posts: $e");
      setState(() {
        isLoading = false; // Stop loading even if there's an error
      });
    }
  }

  // Function to handle post deletion by setting isActive to false
  Future<void> _deletePost(String postId) async {
    try {
      final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

      // Update the 'isActive' field to false instead of deleting the post
      await postRef.update({
        'isActive': false, // Mark post as inactive
      });

      // Reload the posts after deletion
      _fetchUserPosts();
      
      print("Post with ID $postId marked as inactive.");
    } catch (e) {
      print("Error deleting post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter out posts where isActive is false
    final activePosts = posts.where((post) => post.isActive).toList();

    // Debugging output
    print("Number of active posts to display: ${activePosts.length}");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: ShaderMask(
          shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
          child: const Text(
            "COACHY",
            style: TextStyle(
              color: Colors.amberAccent,
              fontSize: 36,
              fontFamily: 'Jersey15',
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner when fetching posts
          : activePosts.isEmpty
              ? const Center(child: Text('No active posts available'))
              : ListView.builder(
                  itemCount: activePosts.length,
                  itemBuilder: (context, index) {
                    final post = activePosts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  post.username,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                // Popup menu with delete option (3-dot menu)
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _deletePost(post.id); // Call delete post function
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete Post'),
                                      ),
                                    ];
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(post.description),
                            const SizedBox(height: 10),
                            Text('Available Dates:'),
                            for (var entry in post.availableDates.entries)
                              Text('${entry.key}: ${entry.value.join(', ')}'),
                            const SizedBox(height: 10),
                            post.imageUrl.isNotEmpty
                                ? Image.network(post.imageUrl)
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

