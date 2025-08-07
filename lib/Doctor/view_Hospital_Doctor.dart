import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zootopia/Doctor/Function_Doctor/doc_Appbar.dart';
import 'package:zootopia/Doctor/add_hospitals.dart';
import 'package:zootopia/Doctor/mark_leave_Doctor.dart';

class ViewHospitalDoctor extends StatefulWidget {
  @override
  _ViewHospitalDoctorState createState() => _ViewHospitalDoctorState();
}

class _ViewHospitalDoctorState extends State<ViewHospitalDoctor> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<DocumentSnapshot>> getApprovedHospitals() async {
    String doctorId = _auth.currentUser!.uid;

    // Get the doctor document
    var doctorDoc = await _firestore.collection('Doctors').doc(doctorId).get();

    if (!doctorDoc.exists || !doctorDoc.data()!.containsKey('hospitalIds')) {
      return [];
    }

    List<dynamic> hospitalIds = doctorDoc['hospitalIds'];

    // Fetch hospital details for approved hospitals
    var hospitalsQuery = await _firestore
        .collection('Hospital')
        .where(FieldPath.documentId, whereIn: hospitalIds)
        .get();

    return hospitalsQuery.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DocAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddHospitalDoctor()),
          );
        },
        backgroundColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 40,
        ),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: getApprovedHospitals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No approved hospitals found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var hospital = snapshot.data![index];

              return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeavePage(hospitalId: hospital.id),
                      ),
                    );
                  }
                  ,child:  Card(
                margin: EdgeInsets.all(10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hospital['imageUrl'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            hospital['imageUrl'],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 10),
                      Text(
                        hospital['hospitalname'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'District: ${hospital['district']}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        'Email: ${hospital['email']}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              )
              );
            },
          );
        },
      ),
    );
  }
}
