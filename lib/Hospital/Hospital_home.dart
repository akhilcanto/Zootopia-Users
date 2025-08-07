import 'package:flutter/material.dart';
import 'package:zootopia/Hospital/Doctor_Timings_Hospital.dart';
import 'package:zootopia/Hospital/FunctionsHospital/care_appbar.dart';
import 'package:zootopia/Hospital/Leave_request.dart';
import 'package:zootopia/Hospital/LoginHospital.dart';
import 'package:zootopia/Hospital/approve_doctor.dart';
import 'package:zootopia/Hospital/manage_doctors_Hospital.dart';
import 'package:zootopia/Hospital/session_hospital.dart';
import 'package:zootopia/Starting/userSelection.dart';

class HospitalHome extends StatefulWidget {
  @override
  State<HospitalHome> createState() => _HospitalHomeState();
}

class _HospitalHomeState extends State<HospitalHome> {
  String _userEmail = "No Email Found";
  String _hospitalname = "No name";
  String _hospitalphoto = "";
  String hospitalID="";

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    Map<String, dynamic>? hospitalDetails = await SessionHospital.getHospitalDetails();

    setState(() {
      _userEmail = hospitalDetails?['email'] ?? "No Email Found";
      _hospitalname = hospitalDetails?['hospitalname'] ?? "No Name";
      _hospitalphoto = hospitalDetails?['imageUrl'] ?? "";
      hospitalID = hospitalDetails?['uid']??"";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: careAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            // Display Hospital Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage: _hospitalphoto.isNotEmpty ? NetworkImage(_hospitalphoto) : null,
              child: _hospitalphoto.isEmpty
                  ? Icon(Icons.medical_services, size: 50, color: Colors.blue)
                  : null,
            ),

            // SizedBox(height: 10),

            // Display Hospital Name
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  _hospitalname,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: [
                _buildFeatureTile(context, Icons.calendar_today, 'Approve Doctors', ApproveDoctorsPage()),
                _buildFeatureTile(context, Icons.pets, 'Manage Doctor', ManageDoctorHospital()),
                _buildFeatureTile(context, Icons.timer, ' Doctor Timings ', ManageDoctorTimings()),
                _buildFeatureTile(context, Icons.timer, ' Leave Request ', HospitalLeaveApprovalPage(hospitalId: hospitalID)),
              ],
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () {
                SessionHospital.clearSession();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Userselection()),
                );
              },
              child: Text("Log Out"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(BuildContext context, IconData icon, String title, Widget route) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => route,)),
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.black),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
