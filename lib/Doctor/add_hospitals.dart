import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zootopia/Doctor/Function_Doctor/doc_Appbar.dart';
import 'package:zootopia/Doctor/doctor_Nav_bar.dart';
import 'package:zootopia/Doctor/view_Hospital_Doctor.dart';

class AddHospitalDoctor extends StatefulWidget {
  @override
  _AddHospitalDoctorState createState() => _AddHospitalDoctorState();
}

class _AddHospitalDoctorState extends State<AddHospitalDoctor> {
  String? selectedState;
  String? selectedHospitalId;
  String? selectedHospitalPhoto;
  String? selectedHospitalDescription;
  String? selectedHospitalDistrict;
  String? selectedHospitalEmail;
  String? selectedHospitalState;
  bool isFetchingHospitals = true;
  bool isSendingRequest = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<QueryDocumentSnapshot> hospitalList = [];
  Set<String> stateList = {};

  @override
  void initState() {
    super.initState();
    fetchHospitals();
  }

  void fetchHospitals() async {
    setState(() {
      isFetchingHospitals = true;
    });

    String doctorId = _auth.currentUser!.uid;

    var doctorDoc = await _firestore.collection('Doctors').doc(doctorId).get();
    List<dynamic> approvedHospitals =
    doctorDoc.exists ? (doctorDoc.data()?['hospitalIds'] ?? []) : [];

    var snapshot = await _firestore.collection('Hospital').get();

    setState(() {
      hospitalList = snapshot.docs
          .where((hospital) => !approvedHospitals.contains(hospital.id))
          .toList();

      stateList = hospitalList
          .map((hospital) => hospital['state'] as String)
          .toSet(); // Extract unique states

      isFetchingHospitals = false;
    });
  }

  void sendRequest() async {
    if (selectedHospitalId == null) return;

    setState(() {
      isSendingRequest = true;
    });

    String doctorId = _auth.currentUser!.uid;

    var existingRequest = await _firestore
        .collection('DoctorRequests')
        .where('doctorId', isEqualTo: doctorId)
        .where('hospitalId', isEqualTo: selectedHospitalId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existingRequest.docs.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request already sent to this hospital')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Doctor_Nav_Bar(initialIndex: 1,)),
        );
      }
      setState(() {
        isSendingRequest = false;
      });
      return;
    }

    var doctorDoc = await _firestore.collection('Doctors').doc(doctorId).get();
    if (doctorDoc.exists) {
      List<dynamic> hospitals = doctorDoc.data()?['hospitalIds'] ?? [];
      if (hospitals.contains(selectedHospitalId)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('You are already approved for this hospital')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  Doctor_Nav_Bar(initialIndex: 1,)),
          );
        }
        setState(() {
          isSendingRequest = false;
        });
        return;
      }
    }

    await _firestore.collection('DoctorRequests').add({
      'doctorId': doctorId,
      'hospitalId': selectedHospitalId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request sent to hospital for approval')),
      );
    }

    setState(() {
      isSendingRequest = false;
    });

    // Delay navigation slightly to ensure UI updates
    await Future.delayed(Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  Doctor_Nav_Bar(initialIndex: 1,)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DocAppBar(),
      body: isFetchingHospitals
          ? Center(
          child: CircularProgressIndicator()) // Show loading while fetching hospitals
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select State",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedState,
                items: stateList
                    .map((state) =>
                    DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedState = value;
                    selectedHospitalId = null;
                  });
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Select State'),
              ),

              SizedBox(height: 20),

              if (selectedState != null) ...[
                Text("Select Hospital", style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                Column(
                  children: hospitalList
                      .where((hospital) => hospital['state'] == selectedState)
                      .map((hospital) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: hospital['imageUrl'] != null
                            ? Image.network(
                          hospital['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                            : Icon(
                            Icons.local_hospital, size: 50, color: Colors.grey),
                        title: Text(
                          hospital['hospitalname'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('District: ${hospital['district']}'),
                            Text('Email: ${hospital['email']}'),
                          ],
                        ),
                        trailing: selectedHospitalId == hospital.id
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          setState(() {
                            selectedHospitalId = hospital.id;
                            selectedHospitalPhoto = hospital['imageUrl'];
                            selectedHospitalDescription =
                            hospital['description'];
                            selectedHospitalDistrict = hospital['district'];
                            selectedHospitalEmail = hospital['email'];
                            selectedHospitalState = hospital['state'];
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],

              SizedBox(height: 20),

              if (selectedHospitalId != null) ...[
                Text("Selected Hospital Details", style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                if (selectedHospitalPhoto != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(selectedHospitalPhoto!, height: 150),
                  ),

                if (selectedHospitalDescription != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      selectedHospitalDescription!,
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                  ),

                if (selectedHospitalDistrict != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('District: $selectedHospitalDistrict',
                        style: TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey)),
                  ),

                if (selectedHospitalState != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('State: $selectedHospitalState',
                        style: TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey)),
                  ),

                if (selectedHospitalEmail != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Email: $selectedHospitalEmail',
                        style: TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey)),
                  ),
              ],

              SizedBox(height: 20),

              isSendingRequest
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: sendRequest,
                child: Text('Send Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}