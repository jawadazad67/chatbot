import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatbot/uihelper.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signUp(
      String firstName, String lastName, String email, String password) async {
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      UiHelper.CustomAlertBox(context, "Enter required fields");
    } else {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Store additional user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
        });

        Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (ex) {
        UiHelper.CustomAlertBox(context, ex.message.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up Page"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UiHelper.CustomTextField(
                  firstNameController, "First Name", Icons.person, false),
              UiHelper.CustomTextField(
                  lastNameController, "Last Name", Icons.person, false),
              UiHelper.CustomTextField(
                  emailController, "Email", Icons.mail, false),
              UiHelper.CustomTextField(
                  passwordController, "Password", Icons.lock, true),
              const SizedBox(height: 30),
              UiHelper.CustomButton(() {
                signUp(
                  firstNameController.text.trim(),
                  lastNameController.text.trim(),
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
              }, "Sign Up"),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signin');
                },
                child: const Text("Already have an account? Sign In"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
