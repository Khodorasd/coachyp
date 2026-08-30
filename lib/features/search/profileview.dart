import 'package:coachyp/features/search/builder/CoachPostsListWidget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coachyp/colors.dart';
import 'package:coachyp/features/chat/data/chatRoom.dart';
import 'package:coachyp/features/posts/presentation/pages/sessions.dart';

class OtherProfilePage extends StatefulWidget {
  final String userId;

  const OtherProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<OtherProfilePage> createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends State<OtherProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _coachData; // save coach data for messaging and booking

 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: AppColors.s2),
        title: ShaderMask(
          shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
          child: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.amberAccent,
              fontSize: 36,
              fontFamily: 'Jersey15',
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('coaches')
              .doc(widget.userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                  child: Text('Error loading profile',
                      style: TextStyle(color: Colors.white)));
            }
            if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;
            _coachData = data.data() as Map<String, dynamic>?;

            final username = _coachData?['username'] ?? '';
            final type = _coachData?['type'] ?? '';
            final profileUrl = _coachData?['profileImgUrl'] ?? '';
            final bio = _coachData?['bio'] ?? 'No bio available';

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: profileUrl.isNotEmpty
                              ? NetworkImage(profileUrl)
                              : null,
                          child: profileUrl.isEmpty
                              ? const Icon(Icons.person, size: 60, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(username,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(type,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16)),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(bio,
                              style: const TextStyle(color: Colors.black87),
                              textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 30),

                        // Send Message button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_coachData != null) {
                                _sendMessage(context, _coachData!);
                              }
                            },
                            icon: const Icon(Icons.message, color: Colors.white),
                            label: const Text('Send Message',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.s2,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Show Availability button
                        if (_coachData != null && _coachData!['availableDates'] != null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final availableDatesMap =
                                    Map<String, dynamic>.from(_coachData!['availableDates']);
                                final convertedDates = availableDatesMap.map(
                                  (key, value) => MapEntry(key, List<String>.from(value)),
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingPage(
                                      availableDates: convertedDates,
                                      coachUserMap: {
                                        'uid': widget.userId,
                                        'username': _coachData!['username'] ?? '',
                                        'profilepicture': _coachData!['profileImgUrl'] ?? '',
                                        'type': _coachData!['type'] ?? '',
                                      },
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.calendar_month, color: Colors.white),
                              label: const Text('Show Availability',
                                  style: TextStyle(color: Colors.white, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.s2,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              TabBar(
                                controller: _tabController,
                                tabs: const [
                                  Tab(icon: Icon(Icons.grid_on, color: Colors.black)),
                                  
                                ],
                                indicatorColor: AppColors.s2,
                              ),
                              SizedBox(
                                height: 400, // Fix height for TabBarView
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildPostsTab(),
                                    
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 🔥 Send message function
  void _sendMessage(BuildContext context, Map<String, dynamic> coachData) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final chatRoomId = _getChatRoomId(currentUser.uid, widget.userId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoom(
          chatRoomId: chatRoomId,
          userMap: {
            'uid': widget.userId,
            'username': coachData['username'] ?? '',
            'profilepicture': coachData['profileImgUrl'] ?? '',
            'type': coachData['type'] ?? '',
          },
        ),
      ),
    );
  }

  String _getChatRoomId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  // 🔥 Posts tab
  Widget _buildPostsTab() {
    return CoachPostsListWidget(coachId: widget.userId);
  }

  // 🔥 Calendar tab
 
}
