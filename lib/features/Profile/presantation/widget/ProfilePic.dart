import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coachyp/colors.dart';
import 'package:coachyp/features/Profile/presantation/pages/MyAccountPage.dart';
import 'package:coachyp/features/Profile/presantation/pages/UserProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:coachyp/features/Profile/data/DataSources/imagePicker.dart';
import 'package:coachyp/features/Profile/data/remote/profilestoreage.dart';

class ProfilePic extends StatefulWidget {
  const ProfilePic({Key? key}) : super(key: key);

  @override
  _ProfilePicState createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  final Imagepickerr _imagePicker = Imagepickerr();
  final StoreageMethode _storageMethod = StoreageMethode();
  final user = FirebaseAuth.instance.currentUser;

  File? _localImageFile;
  String? imageUrl;
  String? username;
  String userCollection = 'users';

  @override
  void initState() {
    super.initState();
    _loadImageUrl();
  }

  Future<void> _loadImageUrl() async {
    if (user == null) return;

    final uid = user!.uid;
    final usersDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (usersDoc.exists) {
      userCollection = 'users';
      final data = usersDoc.data();
      imageUrl = data?['profileImgUrl'];
      username = data?['username'];
    } else {
      final coachesDoc = await FirebaseFirestore.instance.collection('coaches').doc(uid).get();
      if (coachesDoc.exists) {
        userCollection = 'coaches';
        final data = coachesDoc.data();
        imageUrl = data?['profileImgUrl'];
        username = data?['username'];
      }
    }

    setState(() {});
  }

  Future<void> _pickImage() async {
    try {
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in.")),
        );
        return;
      }

      final source = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Choose Image Source"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'camera'),
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'gallery'),
              child: const Text("Gallery"),
            ),
          ],
        ),
      );

      if (source == null) return;

      final image = await _imagePicker.uploadimg(source);
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image selected.")),
        );
        return;
      }

      setState(() => _localImageFile = image);

      final uploadedUrl = await _storageMethod.uploadImageToStorage("profilePics", image);

      await FirebaseFirestore.instance
          .collection(userCollection)
          .doc(user!.uid)
          .update({'profileImgUrl': uploadedUrl});

      setState(() {
        imageUrl = uploadedUrl;
        _localImageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile image updated")),
      );
    } catch (e) {
      print("Error picking/uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 115,
          width: 115,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                backgroundImage: _localImageFile != null
                    ? FileImage(_localImageFile!)
                    : (imageUrl != null
                        ? NetworkImage(imageUrl!)
                        : const NetworkImage(
                            "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png"))
                        as ImageProvider,
              ),
              Positioned(
                right: -16,
                bottom: 0,
                child: SizedBox(
                  height: 46,
                  width: 46,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: const BorderSide(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFFF5F6F9),
                    ),
                    onPressed: _pickImage,
                    child: SvgPicture.string(cameraIcon),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ShaderMask(
                shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
                child: Text(
          username ?? 'Loading...',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            fontFamily: 'Jersey15',
            color: Colors.black87,
          ),
        ),
              ),
      ],
    );
  }
}

        