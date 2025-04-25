import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coachyp/features/chat/data/chatRoom.dart';

class SearchUserPage extends StatefulWidget {
  const SearchUserPage({super.key});

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _recentChats = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchRecentChats();
      }
    });
  }

  String getChatRoomId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

 void fetchRecentChats() async {
  final currentUid = _auth.currentUser?.uid;
  if (currentUid == null) return;

  final Set<String> contactUids = {};
  final List<Map<String, dynamic>> users = [];

  try {
    final chatsSnapshot = await _firestore.collection('chats').get();

    for (var chatDoc in chatsSnapshot.docs) {
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatDoc.id)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();

      for (var message in messagesSnapshot.docs) {
        final data = message.data();
        final senderId = data['senderId'];
        final receiverId = data['receiverId'];

        if (senderId == currentUid || receiverId == currentUid) {
          final otherUid = senderId == currentUid ? receiverId : senderId;

          if (!contactUids.contains(otherUid)) {
            // 🔍 Try to find in users collection
            DocumentSnapshot userDoc = await _firestore.collection('users').doc(otherUid).get();

            // 🔁 If not found in users, try coaches
            if (!userDoc.exists) {
              userDoc = await _firestore.collection('coaches').doc(otherUid).get();
            }

            if (userDoc.exists && userDoc.data() != null) {
              final userData = userDoc.data()! as Map<String, dynamic>;

              users.add({
                'uid': otherUid,
                'username': userData['username'] ?? 'Unknown',
                'role': userData['role'] ?? 'user',
              });

              contactUids.add(otherUid);
            }
          }
        }
      }
    }

    setState(() {
      _recentChats = users;
    });
    print("✅ Recent chats loaded: ${users.length}");
  } catch (e) {
    print('❌ Error fetching recent chats: $e');
  }
}


  void searchUsers() async {
    setState(() {
      _isLoading = true;
    });

    final query = _searchController.text.trim().toLowerCase();
    final currentUid = _auth.currentUser?.uid;
    List<Map<String, dynamic>> combinedResults = [];

    final userSnapshot = await _firestore.collection('users').get();
    final userResults = userSnapshot.docs
        .where((doc) {
          final data = doc.data();
          final username = (data['username'] ?? '').toString().toLowerCase();
          final role = (data['role'] ?? '').toString().toLowerCase();
          return (username.contains(query) || role.contains(query)) &&
              doc.id != currentUid;
        })
        .map((doc) => {
              'uid': doc.id,
              'username': doc['username'],
              'role': doc['role'],
            })
        .toList();

    final coachSnapshot = await _firestore.collection('coaches').get();
    final coachResults = coachSnapshot.docs
        .where((doc) {
          final data = doc.data();
          final username = (data['username'] ?? '').toString().toLowerCase();
          final role = (data['role'] ?? '').toString().toLowerCase();
          return (username.contains(query) || role.contains(query)) &&
              doc.id != currentUid;
        })
        .map((doc) => {
              'uid': doc.id,
              'username': doc['username'],
              'role': doc['role'],
            })
        .toList();

    combinedResults.addAll(userResults);
    combinedResults.addAll(coachResults);

    final uniqueResults = {
      for (var user in combinedResults) user['uid']: user
    }.values.toList();

    setState(() {
      _searchResults = uniqueResults;
      _isLoading = false;
    });
  }

  void startChat(Map<String, dynamic> selectedUser) {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;

    final chatRoomId = getChatRoomId(currentUid, selectedUser['uid']);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoom(
          chatRoomId: chatRoomId,
          userMap: selectedUser,
        ),
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF173D6A),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            user['username'][0].toUpperCase(),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        title: Text(
          user['username'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          user['role'] ?? 'User',
          style: const TextStyle(
            color: Color(0xFFD4E6F1),
            fontSize: 13,
          ),
        ),
        trailing: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        onTap: () => startChat(user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTyping = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Search Users to Chat',
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => searchUsers(),
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (!isTyping && _recentChats.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Recent Chats",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _recentChats.length,
                      itemBuilder: (context, index) {
                        final user = _recentChats[index];
                        return _buildUserTile(user);
                      },
                    ),
                  ),
                ],
              ),
            )
          else if (isTyping)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Search Results",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Expanded(
                    child: _searchResults.isEmpty
                        ? const Center(child: Text('No users found'))
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final user = _searchResults[index];
                              return _buildUserTile(user);
                            },
                          ),
                  ),
                ],
              ),
            )
          else
            const Expanded(child: Center(child: Text("No recent chats"))),
        ],
      ),
    );
  }
}
