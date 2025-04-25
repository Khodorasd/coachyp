// ignore_for_file: non_constant_identifier_names

import 'package:coachyp/Pages/utli/Sportschooser.dart';
import 'package:coachyp/colors.dart';
import 'package:coachyp/features/chat/data/search_user_page.dart';
import 'package:coachyp/features/posts/presentation/pages/UserPost.dart';
import 'package:coachyp/features/court/presentation/pages/court.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:share_plus/share_plus.dart';

import 'package:coachyp/features/posts/domain/entities/post.dart';
import 'package:coachyp/features/posts/domain/use_cases/fetch_posts.dart';

class Userhomepage extends StatefulWidget {
  const Userhomepage({Key? key}) : super(key: key);

  @override
  State<Userhomepage> createState() => _UserhomepageState();
}

class _UserhomepageState extends State<Userhomepage> {
  final List<String> sportsChoosing = [
    "soccer",
    "tennis",
    "basketball",
    "swimming",
    "running",
  ];

  static const List<IconData> sportsIcons = [
    Icons.sports_soccer,
    Icons.sports_tennis,
    LineIcons.basketballBall,
    LineIcons.swimmingPool,
    LineIcons.running,
  ];

  Future<List<Post>>? _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = Provider.of<FetchPosts>(context, listen: false)();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: ShaderMask(
          shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
          child: const Text(
            "COACHY",
            style: TextStyle(
              color: Colors.amberAccent,
              fontSize: 40,
              fontFamily: 'Jersey15',
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(LineIcons.cog),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(LineIcons.facebookMessenger),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchUserPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: SizedBox(
              height: 140,
              child: ListView.builder(
                itemCount: sportsChoosing.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Sportschooser(
                    sports: sportsChoosing[index],
                    SportIcon: sportsIcons[index],
                  );
                },
              ),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
            child: const Text(
              " Posts ",
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 30,
                fontFamily: 'Jersey15',
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Loader while fetching posts
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.s2,
                    ),
                  );
                } else if (snapshot.hasError) {
                  // Error handling
                  return Center(
                    child: Text('Error loading posts: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  final posts = snapshot.data!;

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final p = posts[index];

                      print('Rendering post image URL: ${p.imageUrl}');

                      return Userpost(
                        name: p.coachId,
                        imageUrl: p.imageUrl,
                        desc: p.description,
                        sportcoach: 'Coach', 
                      );
                    },
                  );
                } else {
                  // No posts
                  return const Center(
                    child: Text('No posts available'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
