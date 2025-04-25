import 'dart:io';
import 'package:coachyp/features/auth/data/model/repositories_impl/auth_repository_impl.dart';
import 'package:coachyp/features/auth/domain/Enteties/user_entity.dart';
import 'package:coachyp/features/auth/domain/Repo/auth_repository.dart';
import 'package:coachyp/features/auth/domain/UseCases/registerCoach.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../../../../colors.dart';

class CoachSignUp extends StatefulWidget {
  const CoachSignUp({super.key});

  @override
  State<CoachSignUp> createState() => _CoachSignUpState();
}

class _CoachSignUpState extends State<CoachSignUp> {
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController name = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool obscureText1 = true;
  bool obscureText2 = true;
  String? confirmPasswordError;
  String? emailError;

  File? selectedDocument;
  String? fileName;

  final authRepository = AuthRepositoryImpl(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/image/spart-club.jpg",
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildLabel("Full Name"),
                    const SizedBox(height: 5),
                    buildInputField(controller: name, hint: "Enter your full name", icon: Icons.person),
                    const SizedBox(height: 15),
                    buildLabel("Email"),
                    const SizedBox(height: 5),
                    buildInputField(
                      controller: email,
                      hint: "Enter your email",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      errorText: emailError,
                    ),
                    const SizedBox(height: 15),
                    buildLabel("Password"),
                    const SizedBox(height: 5),
                    buildInputField(
                      controller: password,
                      hint: "Enter your password",
                      icon: Icons.lock,
                      obscureText: obscureText1,
                      suffix: IconButton(
                        icon: Icon(obscureText1 ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscureText1 = !obscureText1),
                      ),
                    ),
                    const SizedBox(height: 15),
                    buildLabel("Confirm Password"),
                    const SizedBox(height: 5),
                    buildInputField(
                      controller: confirmPasswordController,
                      hint: "Retype your password",
                      icon: Icons.lock_outline,
                      obscureText: obscureText2,
                      errorText: confirmPasswordError,
                      suffix: IconButton(
                        icon: Icon(obscureText2 ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscureText2 = !obscureText2),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: pickDocument,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
                        child: Text(
                          fileName == null ? "Upload Document" : "Selected: $fileName",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(color: Colors.white, indent: 50, endIndent: 50),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
                          child: const Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.amberAccent, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacementNamed("Login"),
                          child: const Text(
                            "Go back",
                            style: TextStyle(
                              color: AppColors.s2,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscureText = false,
    Widget? suffix,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffix,
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ShaderMask(
        shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.amberAccent),
        ),
      ),
    );
  }

  Future<void> showLoadingDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Image.asset(
              'assets/gif/icon loading GIF.gif',
              width: 150,
              height: 150,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> handleSignUp() async {
    setState(() {
      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      emailError = !emailRegExp.hasMatch(email.text) ? "Enter a valid email" : null;
      confirmPasswordError = password.text != confirmPasswordController.text
          ? "Passwords do not match"
          : null;
    });

    if (selectedDocument == null) {
      await AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: "Document Required",
        desc: "Please upload a certification or license document.",
      ).show();
      return;
    }

    if (emailError == null && confirmPasswordError == null) {
      await showLoadingDialog(context);
      try {
        final user = UserEntity(
          email: email.text.trim(),
          username: name.text.trim(),
          password: password.text.trim(),
          role: "coach",
          status: "pending",
        );

        final usecase = RegisterCoach(authRepository);
        await usecase.call(user, selectedDocument!);

        Navigator.of(context).pop(); // Close loading

        await AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: "Submitted",
          desc: "Your application is under review. Please check your email and verify yours.",
        ).show();

        Navigator.of(context).pushReplacementNamed("Login");
      } on FirebaseAuthException catch (e) {
        Navigator.of(context).pop(); // Close loading
        if (e.code == 'email-already-in-use') {
          await AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            title: 'Email In Use',
            desc: 'An account already exists for this email.',
          ).show();
        }
      }
    }
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedDocument = File(result.files.single.path!);
        fileName = result.files.single.name;
      });
    }
  }
}
