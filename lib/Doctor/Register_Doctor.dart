import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zootopia/Doctor/Controller/Doctor_Controller.dart';
import 'package:zootopia/Doctor/Function_Doctor/doc_Appbar.dart';
import 'package:zootopia/Doctor/LoginDoctor.dart';

class RegisterDoctor extends StatefulWidget {
  const RegisterDoctor({Key? key}) : super(key: key);

  @override
  _RegisterDoctorState createState() => _RegisterDoctorState();
}

class _RegisterDoctorState extends State<RegisterDoctor> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _specializationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repasswordController = TextEditingController();
  final doctorController _doctorController = doctorController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // upload cheyan photo
  Future<String?> _uploadImage(File image) async {
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child(
          "doctor_profiles/${DateTime.now().millisecondsSinceEpoch}.jpg");

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
    _specializationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl;

      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      String? result = await _doctorController.registerDoctor(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          imageUrl,
          _specializationController.text.trim());

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginDoctor()));
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
      appBar: DocAppBar(),
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
                    child: _image == null
                        ? Icon(Icons.camera_alt, size: 40)
                        : null,
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _specializationController,
                  decoration: InputDecoration(
                      labelText: 'Specialization',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your specialization';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: _submitForm,
                        child: const Text(
                          'Register',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
