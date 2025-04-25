import 'dart:io';
import 'dart:typed_data';

import 'package:coachyp/features/posts/domain/entities/post.dart';
import 'package:coachyp/features/posts/domain/use_cases/create_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _descriptionController = TextEditingController();
  XFile? _pickedFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedFile = picked);
    }
  }

  Future<void> _submitPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final description = _descriptionController.text.trim();

    if (description.isEmpty && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add text or image")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? imageUrl;
    if (_pickedFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref('post_images/$uid/${const Uuid().v4()}.jpg');

      if (kIsWeb) {
        final bytes = await _pickedFile!.readAsBytes();
        final uploadTask = await storageRef.putData(bytes);
        imageUrl = await uploadTask.ref.getDownloadURL();
      } else {
        final file = File(_pickedFile!.path);
        final uploadTask = await storageRef.putFile(file);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }
    }

    final post = Post(
      id: const Uuid().v4(),
      coachId: uid,
      description: description,
      imageUrl: imageUrl ?? '',
      timestamp: DateTime.now(),
      likes: [],
    );

    try {
      final createPost = Provider.of<CreatePost>(context, listen: false);
      await createPost(post);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created!")),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _pickedFile = null;
        _descriptionController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write something...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_pickedFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.grey[200],
                  height: 200,
                  child: kIsWeb
                      ? FutureBuilder<Uint8List>(
                          future: _pickedFile!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            } else {
                              return const Center(child: Text("Failed to load image"));
                            }
                          },
                        )
                      : Image.file(
                          File(_pickedFile!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Add Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade200,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Post',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
