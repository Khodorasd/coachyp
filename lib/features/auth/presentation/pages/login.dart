import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coachyp/features/auth/presentation/pages/User_sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../colors.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool _obscureText = true;
  String? emailError;
  String? passwordError;

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
              ShaderMask(
                shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
                child: const Text(
                  "LOGIN",
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 36,
                    fontFamily: 'Jersey15',
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildLabel("Email"),
                    const SizedBox(height: 6),
                    buildInputField(
                      controller: email,
                      hint: "Enter your email",
                      icon: Icons.email,
                      errorText: emailError,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    buildLabel("Password"),
                    const SizedBox(height: 6),
                    buildInputField(
                      controller: password,
                      hint: "Enter your password",
                      icon: Icons.lock,
                      obscureText: _obscureText,
                      errorText: passwordError,
                      suffix: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: ShaderMask(
                          shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(fontSize: 15, fontFamily: 'Jersey15'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    const Divider(color: Colors.white, indent: 60, endIndent: 60),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
                      child: const Text(
                        "OR",
                        style: TextStyle(fontSize: 18, color: Colors.amberAccent),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.white, indent: 60, endIndent: 60),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(FontAwesomeIcons.google, color: Colors.redAccent),
                      label: const Text(
                        "Sign in with Google",
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
                          child: const Text(
                            "Don't have an account? ",
                            style: TextStyle(fontSize: 16, fontFamily: 'Jersey15'),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacementNamed("sign_up"),
                          child: const Text(
                            "Sign up",
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
  

 Future<void> handleLogin() async {
  setState(() {
    emailError = email.text.isEmpty ? "This can't be empty" : null;
    passwordError = password.text.isEmpty ? "This can't be empty" : null;
  });

  if (emailError == null && passwordError == null) {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      if (!credential.user!.emailVerified) {
        await AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          title: 'Verify Email',
          desc: 'Please verify your email before logging in.',
        ).show();
        return;
      }

      final uid = credential.user!.uid;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        Navigator.of(context).pushReplacementNamed("HomePage");
        return;
      }

      final coachDoc = await FirebaseFirestore.instance.collection('coaches').doc(uid).get();

      if (coachDoc.exists) {
        final coachData = coachDoc.data();
        if (coachData != null && coachData['status'] == 'pending') {
          await AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            title: 'Account Pending',
            desc: 'Your account is awaiting admin approval.',
          ).show();

          await FirebaseAuth.instance.signOut();
          return;
        }

        Navigator.of(context).pushReplacementNamed("HomePage");
        return;
      }

      await AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'User Not Found',
        desc: 'No user data found. Please contact support.',
      ).show();

    } on FirebaseAuthException {
      await AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Login Failed',
        desc: 'Invalid email or password.',
      ).show();
    } catch (e) {
      await AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: 'Something went wrong. Please try again.',
      ).show();
    }
  }
}


}
