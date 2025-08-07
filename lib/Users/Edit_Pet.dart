import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class EditPetScreen extends StatefulWidget {
  final String petID;

  const EditPetScreen({super.key, required this.petID});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _petBreedController = TextEditingController();
  final TextEditingController _petCategoryController = TextEditingController();
  final TextEditingController _petDescriptionController = TextEditingController();

  String? _petGender;
  String? _petImageUrl;
  File? _newImageFile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPetDetails();
  }

  /// Fetches pet details from Firestore
  void fetchPetDetails() async {
    DocumentSnapshot petSnapshot = await FirebaseFirestore.instance
        .collection('Pets_details')
        .doc(widget.petID)
        .get();

    if (petSnapshot.exists) {
      Map<String, dynamic> petData = petSnapshot.data() as Map<String, dynamic>;

      print("Fetched gender from Firestore: ${petData['gender']}"); // Debugging print

      setState(() {
        _petNameController.text = petData['petName'] ?? '';
        _petBreedController.text = petData['breed'] ?? '';
        _petCategoryController.text = petData['petcategory'] ?? '';
        _petDescriptionController.text = petData['petdescription'] ?? '';
        _petGender = petData['gender']; // Ensure this is properly assigned
        _petImageUrl = petData['imageUrl'];
        isLoading = false;
      });

      print("Updated _petGender: $_petGender"); // Debugging print
    }
  }


  /// Allows user to pick a new image
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  /// Saves the updated pet details to Firestore
  Future<void> savePetDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    String? imageUrl = _petImageUrl;

    try {
      // If a new image was selected, upload it to Firebase Storage
      if (_newImageFile != null) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('pet_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

        UploadTask uploadTask = storageRef.putFile(_newImageFile!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Update pet details in Firestore
      await FirebaseFirestore.instance
          .collection('Pets_details')
          .doc(widget.petID)
          .update({
        'petName': _petNameController.text.trim(),
        'breed': _petBreedController.text.trim(),
        'petcategory': _petCategoryController.text.trim(),
        'petdescription': _petDescriptionController.text.trim(),
        'gender': _petGender,
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pet details updated successfully!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update pet details: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zootopiaAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Pet Image (Existing or New)
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _newImageFile != null
                        ? FileImage(_newImageFile!) as ImageProvider
                        : (_petImageUrl != null
                        ? NetworkImage(_petImageUrl!)
                        : AssetImage('asset/placeholder_pet.png')) as ImageProvider,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: Icon(Icons.edit, color: Colors.blue),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Pet Name
                TextFormField(
                  controller: _petNameController,
                  decoration: InputDecoration(labelText: "Pet Name", border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? "Please enter pet name" : null,
                ),

                const SizedBox(height: 10),

                // Pet Breed
                TextFormField(
                  controller: _petBreedController,
                  decoration: InputDecoration(labelText: "Breed", border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? "Please enter breed" : null,
                ),

                const SizedBox(height: 10),

                // Pet Category
                TextFormField(
                  controller: _petCategoryController,
                  decoration: InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? "Please enter category" : null,
                ),

                const SizedBox(height: 10),

                // Pet Description
                TextFormField(
                  controller: _petDescriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                      labelText: "Description", border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? "Please enter description" : null,
                ),

                const SizedBox(height: 10),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: (_petGender == 'Male' || _petGender == 'Female') ? _petGender : null,
                  items: ['Male', 'Female']
                      .map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _petGender = value;
                    });
                  },
                  decoration: InputDecoration(labelText: "Gender", border: OutlineInputBorder()),
                  validator: (value) => value == null ? "Please select a gender" : null,
                ),

                const SizedBox(height: 20),

                // Save Button
                ElevatedButton(
                  onPressed: savePetDetails,
                  child: Text("Save Changes"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
