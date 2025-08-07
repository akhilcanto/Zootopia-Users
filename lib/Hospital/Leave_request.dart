import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zootopia/Hospital/FunctionsHospital/care_appbar.dart';
class HospitalLeaveApprovalPage extends StatelessWidget {
  final String hospitalId;

  HospitalLeaveApprovalPage({required this.hospitalId});

  Future<void> _updateLeaveStatus(BuildContext context, String doctorId,
      String leaveId, String status, List leaveDates) async {
    final doctorRef = FirebaseFirestore.instance
        .collection('Hospital')
        .doc(hospitalId)
        .collection('doctors')
        .doc(doctorId);

    final leaveRef = doctorRef.collection('leaveRequests').doc(leaveId);

    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Update request status
    batch.update(leaveRef, {'status': status});

    // If approved, add leave dates to doctor's `leave` field
    if (status == 'approved') {
      batch.update(doctorRef, {
        'leave': FieldValue.arrayUnion(leaveDates),
      });
    }

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Leave request $status")),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: careAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Hospital')
            .doc(hospitalId)
            .collection('doctors')
            .snapshots(),
        builder: (context, doctorSnapshot) {
          if (!doctorSnapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final doctorDocs = doctorSnapshot.data!.docs;

          return ListView(
            children: doctorDocs.map((doctor) {
              final doctorId = doctor.id;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Hospital')
                    .doc(hospitalId)
                    .collection('doctors')
                    .doc(doctorId)
                    .collection('leaveRequests')
                    .where('status', isEqualTo: 'pending')
                    .orderBy('requestedAt', descending: true)
                    .snapshots(),
                builder: (context, leaveSnapshot) {
                  if (!leaveSnapshot.hasData ||
                      leaveSnapshot.data!.docs.isEmpty) return SizedBox();

                  final leaveDocs = leaveSnapshot.data!.docs;

                  return Column(
                    children: leaveDocs.map((leaveDoc) {
                      final List leaveDates = leaveDoc['leaveDates'];
                      final String reason = leaveDoc['reason'];
                      final Timestamp requestedAt = leaveDoc['requestedAt'];
                      final leaveId = leaveDoc.id;

                      return Card(
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          title: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('Doctors').doc(doctorId).get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return Text("Loading...");
                              final doctorName = snapshot.data!['doctorname'] ?? 'Unknown';
                              return Text(
                                "Dr. $doctorName\nDates:\n${leaveDates.join(',\n')}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              );
                            },
                          ),

                          subtitle: Text(
                              "Reason: $reason\nRequested: ${DateFormat(
                                  'yyyy-MM-dd HH:mm').format(
                                  requestedAt.toDate())}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  _updateLeaveStatus(
                                    context,
                                    doctorId,
                                    leaveId,
                                    'approved',
                                    List<String>.from(leaveDates),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  _updateLeaveStatus(
                                    context,
                                    doctorId,
                                    leaveId,
                                    'rejected',
                                    [],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}