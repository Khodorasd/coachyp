import 'package:coachyp/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({Key? key}) : super(key: key);

  final String email = 'support@coachyp.com';
  final String phone = '+96170458778';

  Future<void> _launchEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Help Needed&body=Hello Coachy Support,',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $email';
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
        backgroundColor: AppColors.primary,
      ),
      body: 
      
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Need Assistance?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "We're here to help you. Feel free to contact us via:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.s2),
              title: Text(email),
              onTap: () => _launchEmail(email),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.s2),
              title: Text(phone),
              onTap: () => _launchPhone(phone),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
    );
  }
}
