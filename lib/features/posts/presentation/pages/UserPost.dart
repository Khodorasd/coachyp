import 'package:coachyp/colors.dart';
import 'package:coachyp/features/posts/presentation/pages/sessions.dart';
import 'package:coachyp/features/search/profileview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPost extends StatefulWidget {
  final String postId;
  final String username;
  final String type;
  final String imageUrl;
  final String desc;
  final String profileImgUrl;
  final List<String> likes;
  final String coachId;
  final Map<String, List<String>> availableDates; // Add availableDates map

  const UserPost({
    Key? key,
    required this.postId,
    required this.username,
    required this.imageUrl,
    required this.desc,
    required this.type,
    required this.profileImgUrl,
    required this.likes,
    required this.coachId,
    required this.availableDates, // Pass availableDates
  }) : super(key: key);

  @override
  State<UserPost> createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  late bool isLiked;
  late int likeCount;
  bool isProcessingLike = false;

  @override
  void initState() {
    super.initState();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    isLiked = currentUserId != null && widget.likes.contains(currentUserId);
    likeCount = widget.likes.length;
  }

  Future<void> _toggleLike() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || isProcessingLike) return;

    setState(() => isProcessingLike = true);

    final postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.postId);

    try {
      if (isLiked) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([currentUserId]),
        });
        setState(() {
          isLiked = false;
          likeCount = (likeCount > 0) ? likeCount - 1 : 0;
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([currentUserId]),
        });
        setState(() {
          isLiked = true;
          likeCount += 1;
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
    } finally {
      setState(() => isProcessingLike = false);
    }
  }

  // Navigate to the booking page with availability details
  void _bookSession() {
    if (widget.availableDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No availability selected for this post')),
      );
      return;
    }

    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BookingPage(
      availableDates: widget.availableDates,
      coachUserMap: {
        'uid': widget.coachId,
        'username': widget.username,
        'profilepicture': widget.profileImgUrl,
        'type': widget.type,
      },
    ),
  ),
);

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Header: Profile Info
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OtherProfilePage(userId: widget.coachId),
                            ),
                          );
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          child: widget.profileImgUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    widget.profileImgUrl,
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.person,
                                          color: Colors.white, size: 28);
                                    },
                                  ),
                                )
                              : const Icon(Icons.person,
                                  color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OtherProfilePage(userId: widget.coachId),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.username,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              widget.type,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Description
                if (widget.desc.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      widget.desc,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 8),

                // Post Image
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.imageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const SizedBox(
                                height: 200,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stack) {
                              return const SizedBox(
                                height: 200,
                                child: Center(
                                  child: Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey),
                                ),
                              );
                            },
                          )
                        : const SizedBox(
                            height: 200,
                            child: Center(
                                child:
                                    Icon(Icons.image_not_supported, size: 50)),
                          ),
                  ),
                ),

                // Book Session Button (only show if availability exists)
                if (widget.availableDates.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.s2,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _bookSession,
                      icon: const Icon(Icons.add, color: AppColors.background),
                      label: const Text(
                        "Show Availability",
                        style: TextStyle(
                            color: AppColors.background,
                            fontSize: 18,
                            fontFamily: 'Jersey15'),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Like and Share Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
                onPressed: isProcessingLike ? null : _toggleLike,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: Add share logic
                },
              ),
              if (likeCount > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '$likeCount likes',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Booking Page to show available time slots

