import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final _fommKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_fommKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password reset link send to your email.")));
    }
  }

  Future<void> passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Password reset link send to your email'),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        toolbarHeight: 70,
        title: Image.asset(
          'asset/ZootopiaAppWhite.png',
          height: 40,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
                key: _fommKey,
                child: ListView(
                  children: [
                    Text(
                        "Forgot your password. Don't worry you are safe with us....😊",
                        style: TextStyle(fontSize: 30)),
                    const SizedBox(height: 26),
                    TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                            labelText: 'Enter your email',
                            border: OutlineInputBorder()),
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!emailRex.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        }),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: passwordReset,
                        child: const Text("Send password reset link"))
                  ],
                ))),
      ),
    );
  }
}
