import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../colors.dart';
import 'package:coachyp/features/auth/presentation/pages/login.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            ShaderMask(
              shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
              child: Text(
                "COACHY",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jersey15',
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 12),
            ShaderMask(
              shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
              child: Text(
                "Your path to a healthier life",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Text(
          "Powered by INFINITE.ZONE",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }
}
