import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:coachyp/features/auth/data/model/user_model.dart';
import 'package:coachyp/features/auth/domain/Enteties/user_entity.dart';
import 'package:coachyp/features/auth/domain/Repo/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl(this.firebaseAuth, this.firestore);

  get profileImgUrl => null;

  @override
  Future<void> registerUser(UserEntity user, String password) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: user.email,
      password: password,
    );

    await credential.user!.sendEmailVerification();

    // final userModel = UserModel(
    //   email: user.email,
    //   username: user.username,
    //   role: user.role,
    //   status: user.role == 'coach' ? 'pending' : user.status, password: '',

    // );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .set({
      'username':user.username,
      'email': user.email,
      'uid': credential.user!.uid,
      'status': 'active',
      'role': user.role,
      'profileImgUrl': user.profileImgUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'bio': user.bio,
    });
  }

  @override
Future<void> registerCoachWithDocument(UserEntity user, File documentFile) async {
  try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password!, 
    );

    final storageRef = FirebaseStorage.instance.ref(
      'coach_documents/${DateTime.now().millisecondsSinceEpoch}_${documentFile.path.split('/').last}',
    );
    await storageRef.putFile(documentFile);
    final documentUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('coaches')
        .doc(credential.user!.uid)
        .set({
      'uid': credential.user!.uid,
      'email': user.email,
      'bio': user.bio,
      'username': user.username,
      'role': user.role,
      'status': 'pending',
      'type': user.type,
      'documentUrl': documentUrl,
      'profileImgUrl': user.profileImgUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    
    print('✅ Coach user successfully registered and uploaded to Firestore.');
  } catch (e) {
    print('🔥 Error while uploading coach user: $e');
    rethrow; // Also rethrow if you want to handle it outside
  }
}


  @override
  Future<UserEntity> loginUser(String email, String password) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    final userDoc = await firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

   if (userData != null && userData['role'] == 'coach') {
  if (userData['status'] == 'pending') {
    throw FirebaseAuthException(
      code: '-pending',
      message: 'Your coach account is pending approval by the admin.',
    );
  } else if (userData['status'] == 'disabled') {
    throw FirebaseAuthException(
      code: 'account-disabled',
      message: 'Your coach account has been rejected by the admin.',
    );
  }
}


    return UserEntity(
      email: user.email ?? '',
      username: userData?['username'] ?? '',
      role: userData?['role'] ?? '',
      status: userData?['status'] ?? '',
      password: '',
    );
  }
}