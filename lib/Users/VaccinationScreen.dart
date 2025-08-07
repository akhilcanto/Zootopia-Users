import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class VaccinationScreen extends StatefulWidget {
  final String petId;
  final String petName;  // Add petName here

  const VaccinationScreen({super.key, required this.petId, required this.petName});  // Pass petName

  @override
  _VaccinationScreenState createState() => _VaccinationScreenState();
}


class _VaccinationScreenState extends State<VaccinationScreen> {
  final TextEditingController _vaccineController = TextEditingController();
  DateTime? _selectedDate;
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  void _addVaccination() async {
    if (_vaccineController.text.isNotEmpty && _selectedDate != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('vaccinations')
          .add({
        'vaccineName': _vaccineController.text,
        'dueDate': _selectedDate!.toIso8601String(),
        'petId': widget.petId,
        'petName':widget.petName,
        'status': 'pending',
      });
      _vaccineController.clear();
      setState(() {
        _selectedDate = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vaccination added successfully!')),
      );
    }
  }

  void _markAsCompleted(String docId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('vaccinations')
        .doc(docId)
        .update({'status': 'completed'});
  }

  void _deleteVaccination(String docId) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('vaccinations')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: zootopiaAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(userId)
                    .collection('vaccinations')
                    .where('petId', isEqualTo: widget.petId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No vaccinations added.'));
                  }

                  List<DocumentSnapshot> upcoming = [];
                  List<DocumentSnapshot> missed = [];
                  List<DocumentSnapshot> completed = [];

                  DateTime now = DateTime.now();

                  for (var doc in snapshot.data!.docs) {
                    var data = doc.data() as Map<String, dynamic>;
                    String status = data['status'] ?? 'pending';
                    DateTime dueDate = DateTime.parse(data['dueDate']);

                    if (status == 'completed') {
                      completed.add(doc);
                    } else if (dueDate.isBefore(now)) {
                      missed.add(doc);
                    } else {
                      upcoming.add(doc);
                    }
                  }

                  return ListView(
                    children: [
                      _buildSection('Upcoming Vaccinations', upcoming, Colors.green),
                      _buildSection('Missed Vaccinations', missed, Colors.red),
                      _buildSection('Completed Vaccinations', completed, Colors.blue, showActions: false),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _showAddVaccinationDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSection(String title, List<DocumentSnapshot> docs, Color color, {bool showActions = true}) {
    if (docs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        ...docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            elevation: 3,
            child: ListTile(
              leading: Icon(
                title == 'Completed Vaccinations' ? Icons.done : Icons.vaccines,
                color: color,
              ),
              title: Text(
                data['vaccineName'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Date: ${data['dueDate'].split('T')[0]}'),
              trailing: showActions
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.blue),
                    onPressed: () => _markAsCompleted(doc.id, data),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteVaccination(doc.id),
                  ),
                ],
              )
                  : null,
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showAddVaccinationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Vaccination"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _vaccineController,
                decoration: const InputDecoration(labelText: "Vaccine Name"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedDate == null
                        ? 'Select Date'
                        : 'Selected: ${_selectedDate!.toLocal()}'.split(' ')[0]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _addVaccination();
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
