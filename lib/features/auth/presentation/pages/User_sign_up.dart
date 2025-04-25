import 'package:coachyp/features/auth/data/model/repositories_impl/auth_repository_impl.dart';
import 'package:coachyp/features/auth/domain/Enteties/user_entity.dart';
import 'package:coachyp/features/auth/presentation/pages/Coach_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../../../../colors.dart';

class ClientSignUp extends StatefulWidget {
  const ClientSignUp({super.key});

  @override
  State<ClientSignUp> createState() => _ClientSignUpState();
}

class _ClientSignUpState extends State<ClientSignUp> {
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController Name = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool obscureText1 = true;
  bool obscureText2 = true;
  String? confirmPasswordError;
  String? emailError;

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
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const CoachSignUp()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: ShaderMask(
          shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
          child: const Text(
            " Become a coach ",
            style: TextStyle(
              color: Colors.amberAccent,
              fontSize: 28, // Reduced from 50 to prevent overflow
              fontFamily: 'Jersey15',
            ),
          ),
        ),
                ),
              ),
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildLabel("Full Name"),
                    const SizedBox(height: 5),
                    buildInputField(controller: Name, hint: "Enter your full name", icon: Icons.person),
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
  

  Future<void> handleSignUp() async {
    setState(() {
      final emailRegExp = RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
      emailError = !emailRegExp.hasMatch(email.text) ? "Enter a valid email" : null;
      confirmPasswordError = password.text != confirmPasswordController.text
          ? "Passwords do not match"
          : null;
    });

    if (emailError == null && confirmPasswordError == null) {
      try {
        final userEntity = UserEntity(
          email: email.text.trim(),
          username: Name.text.trim(),
          role: "user",
          status: "active",
          password: password.text.trim(),
        );

        await authRepository.registerUser(userEntity, password.text.trim());

        await AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Success',
          desc: 'Account created! Please verify your email.',
        ).show();

        Navigator.of(context).pushReplacementNamed("Login");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          await AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            title: 'Weak Password',
            desc: 'The password provided is too weak.',
          ).show();
        } else if (e.code == 'email-already-in-use') {
          await AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            title: 'Email In Use',
            desc: 'An account already exists for this email.',
          ).show();
        }
      } catch (e) {
        print("Other error: $e");
      }
    }
  }
}
