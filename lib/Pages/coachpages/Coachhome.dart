import 'package:coachyp/Pages/coachpages/Myposts.dart';
import 'package:coachyp/colors.dart';
import 'package:coachyp/features/Profile/presantation/pages/SettingsPage.dart';
import 'package:coachyp/features/chat/data/search_user_page.dart';
import 'package:coachyp/features/court/presentation/pages/court.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';


class CoachHomePage extends StatefulWidget {
  const CoachHomePage({super.key});

  @override
  State<CoachHomePage> createState() => _CoachHomePageState();
}

class _CoachHomePageState extends State<CoachHomePage> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;

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
              fontSize: 36,
              fontFamily: 'Jersey15',
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: const Icon(LineIcons.cog),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              icon: const Icon(LineIcons.facebookMessenger),
              onPressed: () {
                // Navigate to the search screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchUserPage()),
                );
              },
            ),
          ),
        ],
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
         
          children: [
            SizedBox(height: 27,),
            // Subscription Button
            // SizedBox(
            //   width: double.infinity,
            //   height: 200, // Adjust height as needed
            //   child: ElevatedButton(
            //     onPressed: () {
            //       // Navigate to Subscription Page (replace with actual navigation)
            //       print("Subscription button pressed");
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.s2,
            //       textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(15),
            //       ),
            //     ),
            //     child: const Text('Subscription', style: TextStyle(color: Colors.white)),
            //   ),
            // ),
            // const SizedBox(height: 30),

            // My Posts Button
            SizedBox(
              width: double.infinity,
              height: 200,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to My Posts Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyPostsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.s2,
                  textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('My Posts', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),

            // Nearby Court Button (optional, just as a placeholder here)
            SizedBox(
              width: double.infinity,
              height: 200,
              child: ElevatedButton(
                onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  SportCourtFinder()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.s2,
                  textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Nearby Court', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
