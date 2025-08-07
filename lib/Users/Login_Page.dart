import 'package:flutter/material.dart';
import 'package:zootopia/Users/Signup.dart';
import 'package:zootopia/Users/User_Controller/User_Controller.dart';
import 'package:zootopia/Users/bottomnavbar.dart';
import 'package:zootopia/Users/function/ForgotPassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;
  final UserController _userController = UserController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String? result = await _userController.loginUser(email, password);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Bottomnavbar()),
              (route) => false,  // Removes all previous routes
        );

      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset("asset/White_and_Black_bg_removed.png.png",
                          height: 300),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter email';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Enter Valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                                icon: Icon(_passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25))),
                        obscureText: !_passwordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter password';
                          }
                          return null;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Forgotpassword()));
                              },
                              child: Text("Forgot Password?")),
                        ],
                      ),
                      _isLoading
                          ? CircularProgressIndicator()
                          : Column(children: [
                              SizedBox(
                                  width: 150,
                                  height: 40,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.black),
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white)),
                                      onPressed: _submitForm,
                                      child: Text('Login'))),
                              const SizedBox(height: 16),
                              SizedBox(
                                  width: 150,
                                  height: 40,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.black),
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white)),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UserForm()));
                                      },
                                      child: Text('Sign Up'))),
                              // const SizedBox(height: 16),
                              // SizedBox(
                              //     width: 150,
                              //     height: 40,
                              //     child: ElevatedButton(
                              //         style: ButtonStyle(
                              //             backgroundColor:
                              //                 MaterialStateProperty.all(
                              //                     Colors.black),
                              //             foregroundColor:
                              //                 MaterialStateProperty.all(
                              //                     Colors.white)),
                              //         onPressed: () {
                              //           Navigator.pushReplacement(
                              //               context,
                              //               MaterialPageRoute(
                              //                   builder: (context) =>
                              //                       Bottomnavbar()));
                              //         },
                              //         child: Text('Test')))
                            ])
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }
}
