import 'package:coachyp/Pages/coachpages/Coachhome.dart';
import 'package:coachyp/features/posts/presentation/pages/create_post_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

// Your pages
import 'package:coachyp/Pages/additionalpages/Notifications.dart';
import 'package:coachyp/Pages/userpages/Userhome.dart';
import 'package:coachyp/features/Profile/presantation/pages/UserProfile.dart';
import 'package:coachyp/features/search/searchFor/Searchfor.dart';

// Your color config
import '../../colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late Future<String> _userTypeFuture; // 'user' or 'coach'

  @override
  void initState() {
    super.initState();
    _userTypeFuture = _getUserType();
  }

  Future<String> _getUserType() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // First check if user exists in 'users' collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return 'user'; // found in users
      }

      // If not found, check 'coaches' collection
      DocumentSnapshot coachDoc = await FirebaseFirestore.instance
          .collection('coaches')
          .doc(user.uid)
          .get();
      if (coachDoc.exists) {
        return 'coach'; // found in coaches
      }

      // If not found in either, default fallback
      return 'user';
    }
    return 'user';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _userTypeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Something went wrong: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          final userType = snapshot.data ?? 'user'; // fallback
          final bool isUser = userType == 'user';

          final List<Widget> userPages = [
            const Userhomepage(),
            const TwoTabNavPage(),
             Notificationspage(),
            const ProfileScreen(),
          ];

          final List<Widget> coachPages = [
            const CoachHomePage(),
            const CreatePostPage(),
             Notificationspage(),
            const ProfileScreen(),
          ];

          return Scaffold(
            extendBody: true,
            backgroundColor: AppColors.primary,
            body: Center(
              child: isUser
                  ? userPages.elementAt(_selectedIndex)
                  : coachPages.elementAt(_selectedIndex),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(.1),
                  )
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                  child: GNav(
                    rippleColor: AppColors.background,
                    gap: 8,
                    activeColor: Colors.black,
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: AppColors.background,
                    color: Colors.black,
                    tabs: isUser
                        ? const [
                            GButton(icon: LineIcons.home, text: 'Home'),
                            GButton(icon: LineIcons.search, text: 'Search'),
                            GButton(icon: LineIcons.bell, text: 'Notifications'),
                            GButton(icon: LineIcons.user, text: 'Profile'),
                          ]
                        : const [
                            GButton(icon: LineIcons.home, text: 'Home'),
                            GButton(icon: LineIcons.plusCircle, text: 'Add Post'),
                            GButton(icon: LineIcons.bell, text: 'Notifications'),
                            GButton(icon: LineIcons.user, text: 'Profile'),
                          ],
                    selectedIndex: _selectedIndex,
                    onTabChange: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text('Unexpected error occurred')),
          );
        }
      },
    );
  }
}
