import 'package:coachyp/Stripe_Payment/Payment_manager.dart';
import 'package:coachyp/features/Profile/presantation/pages/HelpCenterPage.dart';
import 'package:coachyp/features/Profile/presantation/pages/MyAccountPage.dart';
import 'package:coachyp/features/Profile/presantation/pages/SettingsPage.dart';
import 'package:coachyp/features/Profile/presantation/widget/ProfileMenu.dart';
import 'package:coachyp/features/Profile/presantation/widget/ProfilePic.dart';
import 'package:coachyp/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
          child: const Text(
            "Profile",
            style: TextStyle(
              color: Colors.amberAccent,
              fontSize: 36,
              fontFamily: 'Jersey15',
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const ProfilePic(),
            const SizedBox(height: 30),
            ProfileMenu(
              text: "My Account",
              icon: "assets/icons/User Icon.svg",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyAccountPage()),
                );
                // Navigate to account details/settings page
              },
            ),
            ProfileMenu(
              text: "Settings",
              icon: "assets/icons/Settings.svg",
              press: () {
                Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
              },
            ),
            ProfileMenu(
              text: "Help Center",
              icon: "assets/icons/Question mark.svg",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpCenterPage()),
                );
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => PaymentManager.makePayment(20, "USD"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              icon: const Icon(Icons.payment, color: Colors.black),
              label: const Text(
                "Make Payment",
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  foregroundColor: Colors.black87,
                  backgroundColor: const Color.fromARGB(255, 215, 71, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil("Login", (_) => false);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


