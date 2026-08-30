// ignore_for_file: non_constant_identifier_names

import 'package:coachyp/Pages/userpages/Sportschooser.dart';
import 'package:coachyp/colors.dart';
import 'package:coachyp/features/Profile/presantation/pages/SettingsPage.dart';
import 'package:coachyp/features/chat/data/search_user_page.dart';
import 'package:coachyp/features/posts/presentation/pages/UserPost.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:coachyp/features/posts/domain/entities/post.dart';
import 'package:coachyp/features/posts/domain/use_cases/fetch_posts.dart';
import 'package:shimmer/shimmer.dart'; // 🆕 Add this import

class Userhomepage extends StatefulWidget {
  const Userhomepage({Key? key}) : super(key: key);

  @override
  State<Userhomepage> createState() => _UserhomepageState();
}

class _UserhomepageState extends State<Userhomepage> {
  final List<String> sportsChoosing = [
    "All",
    "soccer",
    "tennis",
    "basketball",
    "swimming",
    "Fitness",
  ];

  static const List<IconData> sportsIcons = [
    Icons.clear_all_outlined,
    Icons.sports_soccer,
    Icons.sports_tennis,
    LineIcons.basketballBall,
    LineIcons.swimmingPool,
    LineIcons.dumbbell,
  ];

  final Map<String, List<String>> categoryMapping = {
    "All": [],
    "soccer": ["football coach"],
    "tennis": ["tennis coach"],
    "basketball": ["basketball coach"],
    "swimming": ["swimming coach"],
    "Fitness": ["fitness coach"],
  };

  Future<List<Post>>? _postsFuture;
  String selectedSport = "All";

  @override
  void initState() {
    super.initState();
    fetchPostsForCategory("All");
  }

  Future<void> fetchPostsForCategory(String category) async {
    setState(() {
      selectedSport = category;
    });

    _postsFuture =
        Provider.of<FetchPosts>(context, listen: false)().then((posts) {
      if (category.toLowerCase() == "all") {
        return posts;
      }

      final allowedTypes = (categoryMapping[category] ?? [])
          .map((e) => e.toLowerCase())
          .toList();

      return posts
          .where((post) => allowedTypes.contains(post.type.toLowerCase()))
          .toList();
    });
  }

  Future<void> refreshPosts() async {
    await fetchPostsForCategory(selectedSport);
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
          onPressed: () {
            Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
          },
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
                  return GestureDetector(
                    onTap: () {
                      fetchPostsForCategory(sportsChoosing[index]);
                    },
                    child: Sportschooser(
                      sports: sportsChoosing[index],
                      SportIcon: sportsIcons[index],
                      isSelected: selectedSport == sportsChoosing[index],
                    ),
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
            child: RefreshIndicator(
              onRefresh: refreshPosts,
              child: FutureBuilder<List<Post>>(
                future: _postsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // 🆕 Show shimmer loading
                    return ListView.builder(
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading posts: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    final posts = snapshot.data!;

                    if (posts.isEmpty) {
                      return const Center(
                        child: Text('No posts available for this category.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final p = posts[index];

                        return UserPost(
                          postId: p.id,
                          username: p.username,
                          imageUrl: p.imageUrl,
                          desc: p.description,
                          type: p.type,
                          profileImgUrl: p.profileImgUrl,
                          likes: p.likes,
                          coachId: p.coachId,
                          availableDates: p.availableDates,
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('No posts available.'),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
