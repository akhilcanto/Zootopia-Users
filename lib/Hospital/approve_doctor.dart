import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zootopia/Hospital/FunctionsHospital/care_appbar.dart';

class ApproveDoctorsPage extends StatefulWidget {
  @override
  _ApproveDoctorsPageState createState() => _ApproveDoctorsPageState();
}

class _ApproveDoctorsPageState extends State<ApproveDoctorsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false; // Loading state

  Future<List<QueryDocumentSnapshot>> getDoctorRequests() async {
    String hospitalId = _auth.currentUser!.uid; // Assuming hospital admin is logged in
    var snapshot = await _firestore
        .collection('DoctorRequests')
        .where('hospitalId', isEqualTo: hospitalId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs;
  }

  void approveDoctor(String requestId, String doctorId, String hospitalId) async {
    setState(() {
      isLoading = true;
    });

    DocumentReference hospitalRef = _firestore.collection('Hospital').doc(hospitalId);
    DocumentReference doctorRef = hospitalRef.collection('doctors').doc(doctorId);

    // Fetch doctor's details from the Doctors collection
    DocumentSnapshot doctorSnapshot = await _firestore.collection('Doctors').doc(doctorId).get();

    if (!doctorSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doctor not found!')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    Map<String, dynamic> doctorData = doctorSnapshot.data() as Map<String, dynamic>;
    String doctorName = doctorData['doctorname'] ?? 'Unknown';
    String specialization = doctorData['specialization'] ?? 'Unknown';

    // Step 1: Add hospital ID to the doctor's record
    await _firestore.collection('Doctors').doc(doctorId).update({
      'hospitalIds': FieldValue.arrayUnion([hospitalId]),
    });

    // Step 2: Add doctor details inside Hospital -> doctors subcollection
    await doctorRef.set({
      'doctorId': doctorId,
      'doctorname': doctorName,
      'specialization': specialization,
      // 'timing': {'start': 'Not Set', 'end': 'Not Set'}, // Default timing
    });

    // Step 3: Update the DoctorRequests collection to 'approved'
    await _firestore.collection('DoctorRequests').doc(requestId).update({
      'status': 'approved',
    });

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Doctor approved successfully!')),
    );
  }



  void rejectDoctor(String requestId) async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    await _firestore.collection('DoctorRequests').doc(requestId).update({
      'status': 'rejected',
    });

    setState(() {
      isLoading = false; // Hide loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: careAppBar(),
      body: Stack(
        children: [
          FutureBuilder(
            future: getDoctorRequests(),
            builder: (context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.isEmpty) {
                return Center(child: Text('No pending requests'));
              }

              return ListView(
                children: snapshot.data!.map((request) {
                  String doctorId = request['doctorId'];

                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('Doctors').doc(doctorId).get(),
                    builder: (context, doctorSnapshot) {
                      if (!doctorSnapshot.hasData) {
                        return ListTile(title: Text('Loading doctor...'));
                      }

                      var doctorData = doctorSnapshot.data!.data() as Map<String, dynamic>?;
                      String doctorName = doctorData?['doctorname'] ?? 'Unknown';

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text('Dr. $doctorName'),
                          subtitle: Text('Status: ${request['status']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: isLoading
                                    ? null
                                    : () => approveDoctor(
                                  request.id,
                                  doctorId,
                                  request['hospitalId'],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: isLoading
                                    ? null
                                    : () => rejectDoctor(request.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );

            },
          ),

          // Loading overlay
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3), // Transparent background
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
