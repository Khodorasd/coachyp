import 'dart:io';
import 'dart:typed_data';

import 'package:coachyp/Pages/additionalpages/HomePage.dart';
import 'package:coachyp/Pages/coachpages/Coachhome.dart';
import 'package:coachyp/colors.dart';
import 'package:coachyp/features/posts/domain/entities/post.dart';
import 'package:coachyp/features/posts/domain/use_cases/create_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _descriptionController = TextEditingController();
  XFile? _pickedFile;
  bool _isLoading = false;

  DateTime _focusedDay = DateTime.now();
  final Map<String, List<String>> _availableDates = {}; // {dayString: [times]}

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedFile = picked);
    }
  }

  // Image compression for web (reduce image size before upload)
  Future<Uint8List> compressImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(Uint8List.fromList(bytes));

    if (image == null) return bytes;

    final compressedImage = img.encodeJpg(image, quality: 85);  // Compress with quality 85
    return Uint8List.fromList(compressedImage);
  }

  // Function to pick time slots for selected days
  Future<void> _pickTimeForDay(DateTime day) async {
    // Predefined time slots from 8 AM to 9 PM (for example)
    List<String> timeSlots = [];
    for (int i = 8; i < 21; i++) {
      String startTime = '$i:00';
      String endTime = '${i + 1}:00';
      timeSlots.add('$startTime - $endTime');
    }

    // Track the currently selected slots for this day
    final String dayString = day.toIso8601String().split('T').first;
    Set<String> selectedSlots = Set.from(_availableDates[dayString] ?? []);

    // Show the time slots for the user to select from
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select a Time Slot'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: timeSlots.map((slot) {
                    final isSelected = selectedSlots.contains(slot);
                    return GestureDetector(
                      onTap: () {
                        // Toggle selection: if selected, remove it; if not, add it
                        if (isSelected) {
                          selectedSlots.remove(slot);
                        } else {
                          selectedSlots.add(slot);
                        }

                        // Rebuild the dialog to show the updated state (check/uncheck)
                        setState(() {}); // Rebuild the part of the dialog
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                // Toggle the state of the checkbox
                                if (value == true) {
                                  selectedSlots.add(slot);
                                } else {
                                  selectedSlots.remove(slot);
                                }

                                // Update the UI
                                setState(() {});
                              },
                            ),
                            Text(slot),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Update the availableDates with the newly selected time slots
                    setState(() {
                      _availableDates[dayString] = selectedSlots.toList();
                    });

                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Submit the post to Firestore and Firebase Storage
  Future<void> _submitPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final description = _descriptionController.text.trim();

    if (description.isEmpty && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a description or an image")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? imageUrl;
    try {
      if (_pickedFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref('post_images/$uid/${const Uuid().v4()}.jpg');

        if (kIsWeb) {
          final compressedBytes = await compressImage(_pickedFile!);  // Compress the image
          final uploadTask = await storageRef.putData(compressedBytes);
          imageUrl = await uploadTask.ref.getDownloadURL();
        } else {
          final file = File(_pickedFile!.path);
          final uploadTask = await storageRef.putFile(file);
          imageUrl = await uploadTask.ref.getDownloadURL();
        }
      }
    } catch (e) {
      print('🖨️ [ERROR] Image upload failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed: $e")),
      );
      setState(() {
        _isLoading = false;
      });
      return; // Exit early if image upload fails
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('coaches')
        .doc(uid)
        .get();

    final username = userDoc.data()?['username'] ?? '';
    final type = userDoc.data()?['type'] ?? '';
    final profileImgUrl = userDoc.data()?['profileImgUrl'] ?? '';

    // 🖨️ DEBUG: Print availableDates before creating post
    print('🖨️ [DEBUG] availableDates: $_availableDates');

    // ✅ Validate availableDates
    final cleanedAvailableDates = _availableDates.map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );

    final post = Post(
      id: const Uuid().v4(),
      coachId: uid,
      description: description,
      imageUrl: imageUrl ?? '',
      timestamp: DateTime.now(),
      likes: [],
      username: username,
      type: type,
      profileImgUrl: profileImgUrl,
      availableDates: cleanedAvailableDates,
    );

    // 🖨️ DEBUG: Print full Post object details
    print('🖨️ [DEBUG] Created Post:');
    print('  id: ${post.id}');
    print('  coachId: ${post.coachId}');
    print('  description: ${post.description}');
    print('  imageUrl: ${post.imageUrl}');
    print('  availableDates: ${post.availableDates}');

    try {
      final createPost = Provider.of<CreatePost>(context, listen: false);
      await createPost(post);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created successfully!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('🖨️ [ERROR] Failed to create post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create post: $e")),
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
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Create Post', style: TextStyle(fontFamily: 'Jersey15')),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '📝 Add Post Description',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write something amazing...',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                '📸 Upload an Image',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_pickedFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.grey[200],
                    height: 200,
                    child: kIsWeb
                        ? FutureBuilder<Uint8List>( // Compress the image for web
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
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.s2,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                '📅 Select Available Dates & Times',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TableCalendar(
                firstDay: DateTime.now(),  // Restrict the days before today
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  final dayStr = day.toIso8601String().split('T').first;
                  return _availableDates.containsKey(dayStr);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  _focusedDay = focusedDay;
                  _pickTimeForDay(selectedDay);
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '🕑 Your Availability:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_availableDates.isNotEmpty)
                Column(
                  children: _availableDates.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.key),
                      subtitle: Text(entry.value.join(', ')),
                    );
                  }).toList(),
                )
              else
                const Text('No availability selected yet.'),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.s2,
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
                        '🚀 Post',
                        style: TextStyle(fontSize: 18, color: AppColors.background),
                      ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
