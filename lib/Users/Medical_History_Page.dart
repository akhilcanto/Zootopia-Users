import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zootopia/Users/Medical_Records_Screen.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class MedicalHistoryPage extends StatelessWidget {
  final String petID;

  const MedicalHistoryPage({super.key, required this.petID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zootopiaAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MedicalRecordsPage(petID: petID)),
          );
        },
        backgroundColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 40,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Pets_details')
              .doc(petID)
              .collection('medicalRecords')
              .orderBy('date', descending: true) // Order by date (latest first)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No medical history available."));
            }

            var records = snapshot.data!.docs;

            return ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                var record = records[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      record['category'] ?? "Unknown Category",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date: ${record['date'] ?? 'N/A'}"),
                        Text("Diagnosis: ${record['diagnosis'] ?? 'N/A'}"),
                        Text("Veterinarian: ${record['veterinarian'] ?? 'N/A'}"),
                        Text("Hospital: ${record['hospital'] ?? 'N/A'}"),
                        if (record['fileUrl'] != null && record['fileUrl'].isNotEmpty)
                          TextButton(
                            onPressed: () => _viewReport(context, record['fileUrl']),
                            child: Text("View Report", style: TextStyle(color: Colors.blue)),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteRecord(context, record.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _viewReport(BuildContext context, String fileUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportViewerPage(fileUrl: fileUrl),
      ),
    );
  }

  void _deleteRecord(BuildContext context, String recordId) {
    FirebaseFirestore.instance
        .collection('Pets_details')
        .doc(petID)
        .collection('medicalRecords')
        .doc(recordId)
        .delete();
  }
}

class ReportViewerPage extends StatelessWidget {
  final String fileUrl;

  const ReportViewerPage({super.key, required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zootopiaAppBar(),
      body: Center(
        child: Image.network(fileUrl, fit: BoxFit.contain),
      ),
    );
  }
}
