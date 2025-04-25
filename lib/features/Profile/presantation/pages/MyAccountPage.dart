import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coachyp/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  String userCollection = 'users';
  bool isLoading = true;

  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user == null) return;

    final uid = user!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      userData = userDoc.data();
      userCollection = 'users';
    } else {
      final coachDoc = await FirebaseFirestore.instance.collection('coaches').doc(uid).get();
      if (coachDoc.exists) {
        userData = coachDoc.data();
        userCollection = 'coaches';
      }
    }

    _bioController.text = userData?['bio'] ?? '';

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveBio() async {
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection(userCollection)
        .doc(user!.uid)
        .update({'bio': _bioController.text.trim()});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bio updated")),
    );
  }

  Widget buildInfoTile(String label, String? value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.s2),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(value ?? 'N/A',
            style: const TextStyle(fontSize: 16, color: Colors.black87)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: AppColors.primary,
      ),
      body: 
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
            backgroundColor: AppColors.primary, 
              onRefresh: fetchUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundImage: userData?['profileImgUrl'] != null
                                ? NetworkImage(userData!['profileImgUrl'])
                                : const NetworkImage(
                                    "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png"),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userData?['username'] ?? 'Username',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildInfoTile("Email", user!.email, Icons.email_outlined),
                    buildInfoTile("Role", userData?['role'], Icons.verified_user_outlined),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Bio",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Write a short bio...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: saveBio,
                      icon: const Icon(Icons.save,color: AppColors.background,),
                      label: const Text("Save Changes",style: TextStyle(color: AppColors.background),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.s2,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                
              ),
              
            ),
           
    );
  }
}
const cameraIcon =
    '''<svg width="20" height="16" viewBox="0 0 20 16" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M10 12.0152C8.49151 12.0152 7.26415 10.8137 7.26415 9.33902C7.26415 7.86342 8.49151 6.6619 10 6.6619C11.5085 6.6619 12.7358 7.86342 12.7358 9.33902C12.7358 10.8137 11.5085 12.0152 10 12.0152ZM10 5.55543C7.86698 5.55543 6.13208 7.25251 6.13208 9.33902C6.13208 11.4246 7.86698 13.1217 10 13.1217C12.133 13.1217 13.8679 11.4246 13.8679 9.33902C13.8679 7.25251 12.133 5.55543 10 5.55543ZM18.8679 13.3967C18.8679 14.2226 18.1811 14.8935 17.3368 14.8935H2.66321C1.81887 14.8935 1.13208 14.2226 1.13208 13.3967V5.42346C1.13208 4.59845 1.81887 3.92664 2.66321 3.92664H4.75C5.42453 3.92664 6.03396 3.50952 6.26604 2.88753L6.81321 1.41746C6.88113 1.23198 7.06415 1.10739 7.26604 1.10739H12.734C12.9358 1.10739 13.1189 1.23198 13.1877 1.41839L13.734 2.88845C13.966 3.50952 14.5755 3.92664 15.25 3.92664H17.3368C18.1811 3.92664 18.8679 4.59845 18.8679 5.42346V13.3967ZM17.3368 2.82016H15.25C15.0491 2.82016 14.867 2.69466 14.7972 2.50917L14.2519 1.04003C14.0217 0.418041 13.4113 0 12.734 0H7.26604C6.58868 0 5.9783 0.418041 5.74906 1.0391L5.20283 2.50825C5.13302 2.69466 4.95094 2.82016 4.75 2.82016H2.66321C1.19434 2.82016 0 3.98846 0 5.42346V13.3967C0 14.8326 1.19434 16 2.66321 16H17.3368C18.8057 16 20 14.8326 20 13.3967V5.42346C20 3.98846 18.8057 2.82016 17.3368 2.82016Z" fill="#757575"/>
</svg>
''';
