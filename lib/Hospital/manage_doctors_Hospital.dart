import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zootopia/Hospital/FunctionsHospital/care_appbar.dart';

class ManageDoctorHospital extends StatefulWidget {
  @override
  _ManageDoctorHospitalState createState() => _ManageDoctorHospitalState();
}

class _ManageDoctorHospitalState extends State<ManageDoctorHospital> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  Future<List<QueryDocumentSnapshot>> getHospitalDoctors() async {
    String hospitalId = _auth.currentUser!.uid; // Hospital admin ID

    var snapshot = await _firestore
        .collection('Doctors')
        .where('hospitalIds', arrayContains: hospitalId)
        .get();

    return snapshot.docs;
  }

  void removeDoctor(String doctorId) async {
    setState(() {
      isLoading = true; // Show loading
    });

    String hospitalId = _auth.currentUser!.uid;

    WriteBatch batch = _firestore.batch();

    // 1️⃣ Remove hospital ID from doctor's hospital list
    DocumentReference doctorRef = _firestore.collection('Doctors').doc(doctorId);
    batch.update(doctorRef, {
      'hospitalIds': FieldValue.arrayRemove([hospitalId]),
    });

    // 2️⃣ Remove doctor ID from hospital's doctor list
    DocumentReference hospitalRef = _firestore.collection('Hospital').doc(hospitalId);
    batch.update(hospitalRef, {
      'doctorIds': FieldValue.arrayRemove([doctorId]),
    });

    // 3️⃣ Remove doctor entry from Hospital → doctors subcollection
    DocumentReference hospitalDoctorRef = hospitalRef.collection('doctors').doc(doctorId);
    batch.delete(hospitalDoctorRef);

    await batch.commit();

    setState(() {
      isLoading = false; // Hide loading
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Doctor removed successfully')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: careAppBar(),
      body: Stack(
        children: [
          FutureBuilder(
            future: getHospitalDoctors(),
            builder: (context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.isEmpty) {
                return Center(child: Text('No doctors assigned to this hospital'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var doctor = snapshot.data![index];

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(doctor['imageUrl'] ?? 'https://via.placeholder.com/150'),
                      ),
                      title: Text(doctor['doctorname'] ?? 'Unknown Doctor'),
                      subtitle: Text('Specialization: ${doctor['specialization'] ?? 'N/A'}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: isLoading ? null : () => removeDoctor(doctor.id),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
