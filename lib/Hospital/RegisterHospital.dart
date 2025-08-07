import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zootopia/Hospital/Controller/Hospital_Controller.dart';
import 'package:zootopia/Hospital/FunctionsHospital/Locations.dart';
import 'package:zootopia/Hospital/FunctionsHospital/care_appbar.dart';
import 'package:zootopia/Hospital/LoginHospital.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Registerhospital extends StatefulWidget {
  const Registerhospital({super.key});

  @override
  State<Registerhospital> createState() => _RegisterhospitalState();
}

class _RegisterhospitalState extends State<Registerhospital> {
  final _formKey = GlobalKey<FormState>();
  final _HnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final hospitalController _hospitalController = hospitalController();
  String? selectedState;
  String? selectedDistrict;
  String? selectedCity;
  Map<String, Map<String, List<String>>> stateData = {};
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    stateData = LocationData.getStateData();
  }

  // Future<void> fetchStatesAndDistricts() async {
  //   try {
  //     QuerySnapshot querySnapshot =
  //     await FirebaseFirestore.instance.collection('locations').get();
  //     Map<String, Map<String, List<String>>> tempData = {};
  //
  //     for (var doc in querySnapshot.docs) {
  //       if (doc.data() is Map<String, dynamic>) {
  //         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //
  //         if (data.containsKey('districts') && data['districts'] is Map<String, dynamic>) {
  //           Map<String, dynamic> districtsMap = data['districts'];
  //           Map<String, List<String>> districts = {};
  //           districtsMap.forEach((district, cities) {
  //             if (cities is List) {
  //               districts[district] = List<String>.from(cities);
  //             }
  //           });
  //           tempData[doc.id] = districts;
  //         }
  //       }
  //     }
  //
  //     setState(() {
  //       stateData = tempData;
  //     });
  //   } catch (e) {
  //     print("Error fetching data: $e");
  //   }
  // }


  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child("hospital_profiles/${DateTime.now().millisecondsSinceEpoch}.jpg");
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed: $e"), backgroundColor: Colors.red),
      );
      return null;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && selectedState != null && selectedDistrict != null) {
      setState(() => _isLoading = true);

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      String? result = await _hospitalController.registerHospital(
        _HnameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        imageUrl,
        selectedState!,
        selectedDistrict!,
        selectedCity!,
        _descriptionController.text.trim(),
        _phoneController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hospital Registration Successful!')),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginHospital()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill in all fields correctly."),
            backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: careAppBar(),
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
                  controller: _HnameController,
                  decoration: InputDecoration(
                      labelText: 'Hospital Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.local_hospital)),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter Hospital name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      labelText: 'Hospital Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter Hospital email';
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    return emailRegex.hasMatch(value) ? null : 'Please enter a valid email';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.lock)),
                  validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                      labelText: 'Description about your hospital',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.description)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                      labelText: 'Phone no of Hospital',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,

                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select State',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  value: selectedState,
                  isExpanded: true,
                  items: stateData.keys.map((String state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (String? newState) {
                    setState(() {
                      selectedState = newState;
                      selectedDistrict = null;
                      selectedCity = null;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a state' : null,
                ),

                const SizedBox(height: 16),
                if (selectedState != null)
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select District',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    value: selectedDistrict,
                    isExpanded: true,
                    items: stateData[selectedState]!.keys.map((String district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(district),
                      );
                    }).toList(),
                    onChanged: (String? newDistrict) {
                      setState(() {
                        selectedDistrict = newDistrict;
                        selectedCity = null;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a district' : null,
                  ),

                const SizedBox(height: 16),
                if (selectedDistrict != null)
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select City',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    value: selectedCity,
                    isExpanded: true,
                    items: stateData[selectedState]![selectedDistrict]!.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (String? newCity) {
                      setState(() {
                        selectedCity = newCity;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a city' : null,
                  ),


                const SizedBox(height: 24),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  onPressed: _submitForm,
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
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

