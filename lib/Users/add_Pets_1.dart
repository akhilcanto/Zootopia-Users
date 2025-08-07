import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zootopia/Users/add_Pets_2.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';
import 'dart:io';

import 'package:zootopia/Users/function/DrawerBar.dart';


class PetName extends StatefulWidget {
  const PetName({super.key});

  @override
  State<PetName> createState() => _PetNameState();
}

class _PetNameState extends State<PetName> {
  final _formKey = GlobalKey<FormState>();
  final _petNameController = TextEditingController();
  final _dobController = TextEditingController();
  String? gender;
  File? _image;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context, firstDate: DateTime(2000), lastDate: DateTime.now());
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text("Take Photo"),
              onTap: () async {
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() => _image = File(pickedFile.path));
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text("Choose from Gallery"),
              onTap: () async {
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() => _image = File(pickedFile.path));
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
                  const Text(
                    "It takes 20 seconds!",
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? Icon(Icons.camera_alt, size: 40, color: Colors.black54)
                          : null,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: _pickImage,
                    child: Text("Upload Pet's Photo"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pet Name',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _petNameController,
                    decoration: InputDecoration(
                        hintText: 'Mr.Cuddles',
                        prefixIcon: Icon(Icons.pets),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a name';
                      }
                      return null;
                    },
                  ),
                  Row(children: [
                    Radio(
                      value: 'Male',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                        });
                      },
                    ),
                    Icon(Icons.male, color: Colors.blue),
                    Text('Male', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 25),
                    Radio(
                      value: 'Female',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                        });
                      },
                    ),
                    Icon(Icons.female, color: Colors.pink),
                    Text('Female', style: TextStyle(fontSize: 18))
                  ]),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Pet's date of birth",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dobController,
                        decoration: InputDecoration(
                            hintText: 'Select date of birth',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            )),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select date of birth';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.black),
                        foregroundColor: MaterialStateProperty.all(Colors.white)),
                      onPressed: () {
                        if (_formKey.currentState!.validate() && gender != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChoosePetType(
                                petName: _petNameController.text,
                                dob: _dobController.text,
                                gender: gender!,
                                petPhoto: _image,
                              ),
                            ),
                          );
                        } else if (gender == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select a gender')),
                          );
                        }
                      },
                      child: Text('Continue'),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
