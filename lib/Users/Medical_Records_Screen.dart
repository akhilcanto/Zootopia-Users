import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zootopia/Users/Medical_History_Page.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class MedicalRecordsPage extends StatefulWidget {
  final String petID;

  const MedicalRecordsPage({super.key, required this.petID});

  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
/*  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _veterinarianController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();

  Future<void> _addMedicalRecord() async {
    String recordID = FirebaseFirestore.instance.collection('Pets details').doc(widget.petID).collection('medicalRecords').doc().id;

    await FirebaseFirestore.instance.collection('Pets details').doc(widget.petID).collection('medicalRecords').doc(recordID).set({
      'date': DateTime.now().toIso8601String(),
      'diagnosis': _diagnosisController.text,
      'treatment': _treatmentController.text,
      'veterinarian': _veterinarianController.text,
      'prescription': _prescriptionController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Medical Record Added!")));

    _diagnosisController.clear();
    _treatmentController.clear();
    _veterinarianController.clear();
    _prescriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zootopiaAppBar(),
      body: Column(
        children: [
          // Form to Add New Record
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(controller: _diagnosisController, decoration: InputDecoration(labelText: "Diagnosis")),
                TextField(controller: _treatmentController, decoration: InputDecoration(labelText: "Treatment")),
                TextField(controller: _veterinarianController, decoration: InputDecoration(labelText: "Veterinarian")),
                TextField(controller: _prescriptionController, decoration: InputDecoration(labelText: "Prescription")),
                SizedBox(height: 10),
                ElevatedButton(onPressed: _addMedicalRecord, child: Text("Add Record")),
              ],
            ),
          ),

          // Display Existing Records
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Pets details').doc(widget.petID).collection('medicalRecords').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                var records = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    var record = records[index];
                    return ListTile(
                      title: Text(record['diagnosis']),
                      subtitle: Text("Treatment: ${record['treatment']}"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}*/

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _vetDocNameController = TextEditingController();
  final TextEditingController _otherCategoryController = TextEditingController();
  final TextEditingController _vetNameController = TextEditingController();


  File? _selectedFile;

  String? _selectedCategory;
  final List<String> _categories = [
    "Scanning",
    "Surgery",
    "Checkup",
    "Treatment",
    "Others"
  ];

  Future<void> _pickFile() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadFile() async {
    if (_selectedFile == null) return null;

    try {
      String fileName =
          "medical_records/${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(_selectedFile!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  Future<void> _addMedicalRecord() async {
    if (_dateController.text.isEmpty ||
        _conditionController.text.isEmpty ||
        _vetDocNameController.text.isEmpty ||
        _vetNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String recordID = FirebaseFirestore.instance
        .collection('Pets_details')
        .doc(widget.petID)
        .collection('medicalRecords')
        .doc()
        .id;

    String? fileUrl = await _uploadFile();

    await FirebaseFirestore.instance
        .collection('Pets_details')
        .doc(widget.petID)
        .collection('medicalRecords')
        .doc(recordID)
        .set({
      'recordID': recordID,
      'date': _dateController.text,
      'diagnosis': _conditionController.text,
      'veterinarian': _vetDocNameController.text,
      'hospital':_vetNameController.text,
      'category': _selectedCategory == "Others"
          ? _otherCategoryController.text
          : _selectedCategory,
      'fileUrl': fileUrl ?? "", // Save file URL if uploaded
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Medical Record Added!")));

    setState(() {
      _isLoading = false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => MedicalHistoryPage(petID: widget.petID),));

  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zootopiaAppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle("Category"),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration:
                    _inputDecoration("Select a category", Icons.category),
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              if (_selectedCategory == "Others") SizedBox(height: 10),
              if (_selectedCategory == "Others")
                _buildTextField(_otherCategoryController, "Specify Category",
                    Icons.category),
              SizedBox(height: 10),
              _buildTextField(
                  _conditionController, "Condition/Diagnosis", Icons.healing),
              _buildTextField(
                  _vetDocNameController, "Veterinarian Name", Icons.person),
              _buildTextField(
                  _vetNameController, "Hospital Name", Icons.local_hospital),
              _buildTextField(
                  _dateController, "Date (YYYY-MM-DD)", Icons.date_range,
                  isDate: true),
              SizedBox(height: 15),
              Center(
                child: _selectedFile != null
                    ? Image.file(_selectedFile!,
                        height: 120, width: 120, fit: BoxFit.cover)
                    : Text("No file selected",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: Icon(Icons.upload_file, color: Colors.white),
                  label: Text("Upload Medical Report"),
                  style: _buttonStyle(Colors.lightBlue[300]!),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addMedicalRecord,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Save Record"),
                  style: _buttonStyle(Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(label, icon),
        readOnly: isDate,
        onTap: isDate ? () => _selectDate(controller) : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueGrey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }
}
