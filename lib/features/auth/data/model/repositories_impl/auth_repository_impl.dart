
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coachyp/features/auth/data/model/user_model.dart';
import 'package:coachyp/features/auth/domain/Enteties/user_entity.dart';
import 'package:coachyp/features/auth/domain/Repo/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl(this.firebaseAuth, this.firestore);

  @override
  Future<void> registerUser(UserEntity user, String password) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: user.email,
      password: password,
    );

    await credential.user!.sendEmailVerification();

    final userModel = UserModel(
      email: user.email,
      username: user.username,
      role: user.role,
      status: user.role == 'coach' ? 'pending' : user.status, password: '',
      
    );

    await firestore
    .collection('users')
    .doc(credential.user!.uid)
    .set({
      ...userModel.toMap(),
      'email': user.email,
      'password': password, // ⚠️ Don't use in production
    });

  }
  @override
  Future<void> registerCoachWithDocument(UserEntity user, File documentFile) async {
  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: user.email,
    password: user.password!, // add password to entity if needed
  );

  final storageRef = FirebaseStorage.instance.ref(
    'coach_documents/${DateTime.now().millisecondsSinceEpoch}_${documentFile.path.split('/').last}',
  );
  await storageRef.putFile(documentFile);
  final documentUrl = await storageRef.getDownloadURL();

 await FirebaseFirestore.instance.collection('coaches').doc(credential.user!.uid).set({
  'uid': credential.user!.uid,
  'email': user.email,

  'username': user.username,
  'role': user.role,
  'status': 'pending',
  'documentUrl': documentUrl,
  'createdAt': FieldValue.serverTimestamp(),
});


  await FirebaseAuth.instance.currentUser?.sendEmailVerification();
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

    if (userData != null && userData['role'] == 'coach' && userData['status'] == 'pending') {
      throw FirebaseAuthException(
        code: 'account-pending',
        message: 'Your coach account is pending approval by the admin.',
      );
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
