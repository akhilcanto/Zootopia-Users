import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:zootopia/Users/Session.dart';
import 'package:zootopia/Users/bottomnavbar.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class petBreed extends StatefulWidget {
  final String petcategory;
  final String petName;
  final String dob;
  final String gender;
  final File? petPhoto;

  const petBreed(
      {Key? key,
      required this.petcategory,
      required this.petName,
      required this.dob,
      required this.gender,
      required this.petPhoto});

  @override
  State<petBreed> createState() => _petBreedState();
}

class _petBreedState extends State<petBreed> {
  final _formKey = GlobalKey<FormState>();
  final _breedController = TextEditingController();
  final _petColorController = TextEditingController();
  final _petDescriptionController=TextEditingController();
  bool _isLoading = false;
  late String uidd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  Future<String?> getData() async {
    Map<String, String?> sessionData = await SessionUser.getSession();

    print(sessionData['uid']);
    uidd = sessionData['uid']!;
    return uidd;
  }

  String generatePetId(String petCategory) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    // Ensure pet category has at least 4 characters, if not, pad with 'X'
    String categoryPart = (petCategory.length >= 4)
        ? petCategory.substring(0, 4).toUpperCase()
        : petCategory.toUpperCase().padRight(4, 'X');

    // Get last 6 digits of timestamp
    String timestampPart =
        DateTime.now().millisecondsSinceEpoch.toString().substring(7, 13);

    return categoryPart + timestampPart; // Total 10 characters
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String breed = _breedController.text.trim();
    String petcolor = _petColorController.text.trim();
    String petdescription = _petDescriptionController.text.trim();

    // Assign a default description if empty
    if (petdescription.isEmpty) {
      petdescription = "${widget.petName} is a wonderful ${widget.petcategory.toLowerCase()}.";
    }

    String? imageUrl;

    try {
      // Upload image if available
      if (widget.petPhoto != null) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('pet_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

        UploadTask uploadTask = storageRef.putFile(widget.petPhoto!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      String petId = generatePetId(widget.petcategory);

      await FirebaseFirestore.instance.collection('Pets_details').doc(petId).set({
        'petID': petId,
        'ownerID': uidd,
        'petcategory': widget.petcategory,
        'petName': widget.petName,
        'dob': widget.dob,
        'gender': widget.gender,
        'breed': breed,
        'petcolor': petcolor,
        'petdescription': petdescription, // Updated with default value if empty
        'imageUrl': imageUrl ?? "",
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pet details added successfully!')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Bottomnavbar(initialIndex: 0),
        ),
            (route) => false,
      );

      _breedController.clear();
      _petColorController.clear();
      _petDescriptionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add pet: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: zootopiaAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 200,
                    child: Image(image: AssetImage('asset/White_cat.png')),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    // Space between label and TextField
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pet Breed', // Label text
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _breedController,
                    decoration: InputDecoration(
                        hintText: 'Breed',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a Breed';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    // Space between label and TextField
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Color', // Label text
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _petColorController,
                    decoration: InputDecoration(
                        hintText: 'Color',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a color';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    // Space between label and TextField
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Description about  ${widget.petName}', // Label text
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _petDescriptionController,
                    decoration: InputDecoration(
                        hintText: '${widget.petName} is wonder full ${widget.petcategory}',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25))),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Add"),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
