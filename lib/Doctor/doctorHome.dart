import 'package:flutter/material.dart';
import 'package:zootopia/Doctor/Doctors_Appoint_date.dart';
import 'package:zootopia/Doctor/Function_Doctor/doc_Appbar.dart';
import 'package:zootopia/Doctor/Search_medical_records.dart';
import 'package:zootopia/Starting/userSelection.dart';

class DoctorHome extends StatefulWidget {
  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DocAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: [
                _buildFeatureTile(context, Icons.calendar_today, "Today's Appoinment",DoctorTodaysAppointmentsPage()),
                _buildFeatureTile(context, Icons.pets, 'Pet Medical History', SearchMedicalRecords()),
                // _buildFeatureTile(context, Icons.timer, ' Doctor Timings ', ManageDoctorTimings()),
                // _buildFeatureTile(context, Icons.person, 'Doctor Profiles', '/doctorProfiles'),
                // _buildFeatureTile(context, Icons.history, 'Patient History', '/patientHistory'),
                // _buildFeatureTile(context, Icons.notifications, 'Notifications', '/notifications'),
                // _buildFeatureTile(context, Icons.analytics, 'Reports & Analytics', '/reports'),
                // _buildFeatureTile(context, Icons.settings, 'Hospital Settings', '/settings'),
              ],
            ),
            // ElevatedButton(
            //   style: ButtonStyle(
            //     backgroundColor: MaterialStateProperty.all(Colors.black),
            //     foregroundColor: MaterialStateProperty.all(Colors.white),
            //   ),
            //   onPressed: () {
            //     SessionHospital.clearSession();
            //     Navigator.pushReplacement(
            //       context,
            //       MaterialPageRoute(builder: (context) => Userselection()),
            //     );
            //   },
            //   child: Text("Log Out"),
            // ),
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
