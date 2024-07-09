import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatbot/uihelper.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  void resetPassword(String email) async {
    if (email.isEmpty) {
      UiHelper.CustomAlertBox(context, "Please enter your email");
    } else {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        UiHelper.CustomAlertBox(
            context, "Password reset link sent to your email");
        Navigator.pushReplacementNamed(context, '/signin');
      } on FirebaseAuthException catch (ex) {
        UiHelper.CustomAlertBox(context, ex.message.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/signin');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UiHelper.CustomTextField(
                emailController, "Email", Icons.mail, false),
            const SizedBox(height: 30),
            UiHelper.CustomButton(() {
              resetPassword(emailController.text.toString());
            }, "Reset Password"),
          ],
        ),
      ),
    );
  }
}
