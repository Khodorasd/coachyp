import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageMethod {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(String folderName, File file) async {
    try {
      // Create unique filename using UID and timestamp
      final String fileName = '${_auth.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}';
      
      Reference ref = _storage.ref()
        .child(folderName)
        .child(_auth.currentUser!.uid)
        .child(fileName);

      // Upload with progress tracking (optional)
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Upload failed: ${e.toString()}';
    }
  }
}