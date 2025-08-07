import 'package:flutter/material.dart';
import 'package:zootopia/Doctor/LoginDoctor.dart';
import 'package:zootopia/Hospital/Controller/Hospital_Controller.dart';
import 'package:zootopia/Hospital/Hospital_home.dart';
import 'package:zootopia/Hospital/RegisterHospital.dart';
import 'package:zootopia/Users/function/ForgotPassword.dart';

class LoginHospital extends StatefulWidget {
  const LoginHospital({super.key});

  @override
  State<LoginHospital> createState() => _LoginHospitalState();
}

class _LoginHospitalState extends State<LoginHospital> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  final hospitalController _hospitalController=hospitalController();


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String email =_emailController.text.trim();
      String password=_passwordController.text.trim();
      String? result = await _hospitalController.loginHospital(email, password);

      if(result==null)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HospitalHome()),
              (route) => false,  // Removes all previous routes
        );
      } else
      {
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
                      Image.asset("asset/Hospital/LoginPagePhoto.png",
                          height: 300),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Hospital email id',
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
                                icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off)),
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LoginDoctor()));
                              },
                              child: Text("Login as Doctor?")),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.black),
                                  foregroundColor: MaterialStateProperty.all(Colors.white)
                              ),
                              onPressed: _submitForm, child: Text('Login'))
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.black),
                                  foregroundColor: MaterialStateProperty.all(Colors.white)
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Registerhospital()));
                              }, child: Text('Register'))
                      ),
                      // const SizedBox(height: 16),
                      // SizedBox(
                      //     width: 150,
                      //     height: 40,
                      //     child: ElevatedButton(
                      //         style: ButtonStyle(
                      //             backgroundColor: MaterialStateProperty.all(Colors.black),
                      //             foregroundColor: MaterialStateProperty.all(Colors.white)
                      //         ),
                      //         onPressed: () {
                      //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HospitalHome()));
                      //         }, child: Text('Test'))
                      // )
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }
}