import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coachyp/colors.dart';
import 'package:coachyp/features/chat/data/chatRoom.dart';

class BookingPage extends StatelessWidget {
  final Map<String, List<String>> availableDates;
  final Map<String, dynamic> coachUserMap; // 👈 Add coach data here

  const BookingPage({
    Key? key,
    required this.availableDates,
    required this.coachUserMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Times', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.s2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Select a time slot to book a session. You can contact the coach directly if needed.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: availableDates.length,
                itemBuilder: (context, index) {
                  final entry = availableDates.entries.elementAt(index);
                  final day = entry.key;
                  final times = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day Header
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.s2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Display each time slot as a Card
                      for (var time in times)
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12.0),
                            title: Text(
                              time,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _sendMessage(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.s2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Send Message to Coach',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 👉 Send Message Function
  void _sendMessage(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final coachId = coachUserMap['uid'];
    final chatRoomId = _getChatRoomId(currentUser.uid, coachId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoom(
          chatRoomId: chatRoomId,
          userMap: coachUserMap,
        ),
      ),
    );
  }

  // 👉 Helper to generate a consistent Chat Room ID
  String _getChatRoomId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }
}
