import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coachyp/features/chat/data/chatRoom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchUserPage extends StatefulWidget {
  const SearchUserPage({super.key});

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  bool _isFetchingRecentChats = true;

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

    setState(() {
      _isFetchingRecentChats = true;
    });

    final Set<String> contactUids = {};
    final List<Map<String, dynamic>> users = [];

    try {
      final currentUserDoc = await _firestore.collection('users').doc(currentUid).get();
      final currentCoachDoc = await _firestore.collection('coaches').doc(currentUid).get();
      final isCoach = currentCoachDoc.exists;

      final chatsSnapshot = await _firestore.collection('chats').get();

      for (var chatDoc in chatsSnapshot.docs) {
        final messagesSnapshot = await _firestore
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          final lastMessageData = messagesSnapshot.docs.first.data();
          final senderId = lastMessageData['senderId'];
          final receiverId = lastMessageData['receiverId'];
          final isSeenRaw = lastMessageData['isSeen'] ?? true;

          final bool showGreenDot =
              senderId != currentUid &&
              receiverId == currentUid &&
              isSeenRaw == false;

          if (senderId == currentUid || receiverId == currentUid) {
            final otherUid = senderId == currentUid ? receiverId : senderId;

            if (!contactUids.contains(otherUid)) {
              final targetCollection = isCoach ? 'users' : 'coaches';
              final targetDoc = await _firestore.collection(targetCollection).doc(otherUid).get();

              if (targetDoc.exists && targetDoc.data() != null) {
                final data = targetDoc.data()! as Map<String, dynamic>;
                users.add({
                  'uid': otherUid,
                  'username': data['username'] ?? 'Unknown',
                  'type': data['type'] ?? (isCoach ? 'user' : 'coach'),
                  'profilepicture': data['profileImgUrl'] ?? '',
                  'isSeen': !showGreenDot,
                });
                contactUids.add(otherUid);
              }
            }
          }
        }
      }

      setState(() {
        _recentChats = users;
        _isFetchingRecentChats = false;
      });
      print("✅ Recent chats loaded: ${users.length}");
    } catch (e) {
      print('❌ Error fetching recent chats: \$e');
      setState(() {
        _isFetchingRecentChats = false;
      });
    }
  }

  void searchUsers() async {
    setState(() {
      if (_isLoading || _isFetchingRecentChats) ;
    });

    final query = _searchController.text.trim().toLowerCase();
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;

    final currentUserDoc = await _firestore.collection('users').doc(currentUid).get();
    final currentCoachDoc = await _firestore.collection('coaches').doc(currentUid).get();
    final isCoach = currentCoachDoc.exists;

    List<Map<String, dynamic>> combinedResults = [];
    final targetCollection = isCoach ? 'users' : 'coaches';
    final targetSnapshot = await _firestore.collection(targetCollection).get();

    final targetResults = targetSnapshot.docs
    .where((doc) {
      final data = doc.data();
      final username = (data['username'] ?? '').toString().toLowerCase();
      return username.contains(query) && doc.id != currentUid;
    })
    .map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'username': data['username'] ?? 'Unknown',
        'type': data['type'] ?? 'user',
        'profilepicture': data['profileImgUrl'] ?? '',
      };
    })
    .toList();


    combinedResults.addAll(targetResults);

    final uniqueResults =
        {for (var user in combinedResults) user['uid']: user}.values.toList();

    setState(() {
      _searchResults = uniqueResults;
      _isLoading = false;
    });
  }

  void startChat(Map<String, dynamic> selectedUser) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;

    final chatRoomId = getChatRoomId(currentUid, selectedUser['uid']);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoom(
          chatRoomId: chatRoomId,
          userMap: selectedUser,
        ),
      ),
    );

    fetchRecentChats();
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final String profilePicture = user['profilepicture'] ?? '';
    final String username = user['username'] ?? '';
    final bool isSeen = user['isSeen'] ?? true;
    final bool isNewMessage = user['isNewMessage'] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF173D6A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white,
          backgroundImage:
              profilePicture.isNotEmpty ? NetworkImage(profilePicture) : null,
          child: profilePicture.isEmpty && username.isNotEmpty
              ? Text(
                  username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (!isSeen)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Text(
          user['type'] ?? 'User',
          style: const TextStyle(
            color: Color(0xFFD4E6F1),
            fontSize: 13,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          onPressed: () => startChat(user),
        ),
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
          'Chat',
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
            fontFamily: 'Jersey15',
            letterSpacing: 1.1,
            fontSize: 36,
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
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _searchResults.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_isLoading || _isFetchingRecentChats)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (!isTyping && _recentChats.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Recent Chats",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
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