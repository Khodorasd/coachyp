import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coachyp/colors.dart';
import 'package:coachyp/features/posts/presentation/pages/sessions.dart';

class CoachPostsListWidget extends StatelessWidget {
  final String coachId;

  const CoachPostsListWidget({Key? key, required this.coachId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('coachId', isEqualTo: coachId)
          .where('isActive', isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading posts'));
        }

        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs;

        if (posts.isEmpty) {
          return const Center(child: Text('No posts available'));
        }

        return SizedBox(
          height: 400,
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final data = posts[index].data() as Map<String, dynamic>;

              final availableDates = Map<String, List<String>>.from(
                (data['availableDates'] ?? {}).map(
                  (key, value) => MapEntry(key, List<String>.from(value)),
                ),
              );

              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      if (data['description'] != null && data['description'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: Text(
                            data['description'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),

                      // Image
                      if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              data['imageUrl'],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const SizedBox(
                                  height: 200,
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                    ),
                                  ),
                            ),
                          ),
                        ),

                      // Availability Button
                      if (availableDates.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.s2,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingPage(
                                    availableDates: availableDates,
                                    coachUserMap: {
                                      'uid': data['coachId'],
                                      'username': data['username'],
                                      'profilepicture': data['profileImgUrl'],
                                      'type': data['type'],
                                    },
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, color: AppColors.background),
                            label: const Text(
                              "Show Availability",
                              style: TextStyle(
                                color: AppColors.background,
                                fontSize: 18,
                                fontFamily: 'Jersey15',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
