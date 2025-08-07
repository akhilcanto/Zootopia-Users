import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zootopia/Users/Login_Page.dart';
import 'package:zootopia/Users/User_Controller/User_Controller.dart';

class UserForm extends StatefulWidget {
  const UserForm({Key? key}) : super(key: key);

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repasswordController = TextEditingController();
  final UserController _userController = UserController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // upload cheyan photo
  Future<String?> _uploadImage(File image) async {
    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child("user_profiles/${DateTime.now().millisecondsSinceEpoch}.jpg");

      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Image upload error: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {

      setState(() {
        _isLoading=true;
      });

        String? imageUrl;

      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      String? result = await _userController.registerUser(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _phoneController.text.trim(),
        imageUrl,

      );
      setState(() {
        _isLoading=false;
      });
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: Colors.red),
        );

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        toolbarHeight: 70,
        title: Image.asset('asset/ZootopiaAppWhite.png', height: 40,),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null ? Icon(Icons.camera_alt, size: 40) : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.person)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    // final nameRegex = RegExp(r'^([A-Z][a-z]+)( [A-Z][a-z]+)+$')?;
                    // if (!nameRegex.hasMatch(value)) {
                    //   return 'Name must contain only letters and spaces, and be at least 2 characters long';
                    // }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Please enter a valid Indian phone number starting with 6, 7, 8, or 9 and 10 digits long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    final passwordRegex = RegExp(
                        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$');
                    if (!passwordRegex.hasMatch(value)) {
                      return 'Password must have at least 6 characters, include an uppercase letter, a lowercase letter, a number, and a special character';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _repasswordController,
                  decoration: InputDecoration(
                      labelText: 'ReEnter Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    final passwordRegex = RegExp(
                        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$');
                    if (!passwordRegex.hasMatch(value)) {
                      return 'Password must have at least 6 characters, include an uppercase letter, a lowercase letter, a number, and a special character';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _isLoading? CircularProgressIndicator():
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      foregroundColor: MaterialStateProperty.all(Colors.white)
                  ),
                  onPressed: _submitForm,


                  child: const Text('Register',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
