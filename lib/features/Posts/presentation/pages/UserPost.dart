// lib/features/posts/presentation/pages/UserPost.dart
import 'package:coachyp/colors.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class Userpost extends StatelessWidget {
  final String name;
  final String sportcoach;
  final String imageUrl;
  final String desc;

  const Userpost({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.desc,
    required this.sportcoach,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          Container(
            height: 370,
            width: 420,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Header: profile and options
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                sportcoach,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(LineIcons.verticalEllipsis),
                    ],
                  ),
                ),

                // Description text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Post image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(0)),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stack) {
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        )
                      : const SizedBox(
                          height: 200,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                            ),
                          ),
                        ),
                ),

                // Book Session button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.s2,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.add,
                      color: AppColors.background,
                    ),
                    label: const Text(
                      "Book Session",
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

          // Actions: like & share
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.favorite_border),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.share),
              ),
            ],
          ),
        ],
      ),
    );
  }
}