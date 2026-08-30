import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:coachyp/colors.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  const ChatRoom({
    super.key,
    required this.userMap,
    required this.chatRoomId,
  });

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageCtrl = TextEditingController(); 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    markMessagesAsSeen(); // Mark messages as seen when the chat is opened
  }

  // Mark all messages as "seen" when the user opens the chat room
  void markMessagesAsSeen() async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;

    final querySnapshot = await _firestore
        .collection('chats')
        .doc(widget.chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUid)
        .where('isSeen', isEqualTo: false)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'isSeen': true});
    }

    await _firestore.collection('chats').doc(widget.chatRoomId).update({
      'isSeen': true,
    });
  }

  // Clear chat function that deletes all messages
  void clearChat() async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;

    final chatDoc = _firestore.collection('chats').doc(widget.chatRoomId);
    final messageDocs = await chatDoc.collection('messages').get();

    for (var message in messageDocs.docs) {
      await message.reference.delete(); // Deletes each message
    }

    // Optionally, delete the chat room document too
    await chatDoc.delete();

    setState(() {
      Navigator.pop(context); // Close the chat window after clearing the chat
    });
  }

  // Function to show a confirmation dialog before clearing the chat
  void showClearChatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Clear Chat"),
          content: Text("Are you sure you want to clear all messages in this chat? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                clearChat(); // Proceed to clear the chat
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Clear Chat"),
            ),
          ],
        );
      },
    );
  }

  // Send message function
  void sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final messageData = {
      'senderId': user.uid,
      'receiverId': widget.userMap['uid'],
      'message': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isSeen': false,
    };

    await _firestore
        .collection('chats')
        .doc(widget.chatRoomId)
        .collection('messages')
        .add(messageData);

    await _firestore.collection('chats').doc(widget.chatRoomId).set({
      'participants': [user.uid, widget.userMap['uid']],
      'lastMessage': text,
      'timestamp': FieldValue.serverTimestamp(),
      'lastSenderId': user.uid,
      'isSeen': false,
    }, SetOptions(merge: true));

    _messageCtrl.clear();
  }

  // Helper function to check for profile picture and return it, else return the first letter of the username
  Widget _getProfilePictureOrInitials(Map<String, dynamic> user) {
String profilePicture = user['profilepicture'] ?? ''; 
    String username = user['username'] ?? '';
    
    // If profile picture exists, return it, else return the first letter of the username
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white,
      backgroundImage: (profilePicture.isNotEmpty) ? NetworkImage(profilePicture) : null,
      child: (profilePicture.isEmpty && username.isNotEmpty)
          ? Text(
              username[0].toUpperCase(),
              style: const TextStyle(color:Colors.black),
              
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2F6),
      appBar: AppBar(
        backgroundColor: AppColors.s2,
        elevation: 1,
        leading: BackButton(color: Colors.white),
        title: Row(
          children: [
            _getProfilePictureOrInitials(widget.userMap), // Display profile picture or initials
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.userMap['username'] ?? 'Chat',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outlined, color: Colors.white), // Clear chat icon
            onPressed: showClearChatDialog, // Show confirmation dialog
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(widget.chatRoomId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    reverse: true, // Show the latest message at the top
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final isMe = data['senderId'] == currentUid;
                      final timestamp = data['timestamp'] as Timestamp?;
                      final messageTime = timestamp != null
                          ? TimeOfDay.fromDateTime(timestamp.toDate())
                          : null;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 6,
                            bottom: 6,
                            left: isMe ? 60 : 16,
                            right: isMe ? 16 : 60,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? AppColors.s2
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                data['message'] ?? '',
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (messageTime != null)
                                Text(
                                  messageTime.format(context),
                                  style: TextStyle(
                                    color:
                                        isMe ? Colors.white70 : Colors.black54,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        hintText: 'Type a message',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.s2,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}