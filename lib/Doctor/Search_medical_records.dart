import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zootopia/Doctor/Function_Doctor/doc_Appbar.dart';

class SearchMedicalRecords extends StatefulWidget {
  @override
  _SearchMedicalRecordsState createState() => _SearchMedicalRecordsState();
}

class _SearchMedicalRecordsState extends State<SearchMedicalRecords> {
  final TextEditingController _petIDController = TextEditingController();
  List<QueryDocumentSnapshot> _records = [];
  bool _isLoading = false;

  Future<void> _searchRecords() async {
    String petID = _petIDController.text.trim();
    if (petID.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please enter a Pet ID")));
      return;
    }

    setState(() => _isLoading = true);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Pets_details')
        .doc(petID)
        .collection('medicalRecords')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      _records = snapshot.docs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DocAppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _petIDController,
              decoration: InputDecoration(
                labelText: "Enter Pet ID",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchRecords,
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _records.isEmpty
                ? Text("No records found")
                : Expanded(
              child: ListView.builder(
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  var record = _records[index].data() as Map<String, dynamic>;
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

                    ),
                  );
                },
              ),
            ),
          ],
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
}

class ReportViewerPage extends StatelessWidget {
  final String fileUrl;

  const ReportViewerPage({super.key, required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DocAppBar(),
      body: Center(
        child: Image.network(fileUrl, fit: BoxFit.contain),
      ),
    );
  }
}