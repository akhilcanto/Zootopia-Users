import 'package:flutter/material.dart';
import 'package:zootopia/Doctor/Function_Doctor/doc_Appbar.dart';
import 'package:zootopia/Doctor/LoginDoctor.dart';
import 'package:zootopia/Doctor/session_Doctor.dart';
import 'package:zootopia/Starting/userSelection.dart';


class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  String? _userName;
  String? _userEmail;
  String? _userPhoto;
  String?  _specialization;
  bool _isLoading = true; // Added loading state

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    Map<String, dynamic>? userDetails = await SessionDoctor.getDoctorDetails();
    Map<String, String?> sessionData = await SessionDoctor.getSession(); // Fetch from SharedPreferences

    setState(() {
      _userName = userDetails?['doctorname'] ?? "Unknown User";
      _userEmail = userDetails?['email'] ?? "No Email Found";
      _userPhoto =sessionData['imageUrl'];
      _specialization = userDetails?['specialization']??"Loading";
      _isLoading = false; // Set loading to false after fetching data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DocAppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView(
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 100,
                  backgroundImage: _userPhoto != null && _userPhoto!.isNotEmpty
                      ? NetworkImage(_userPhoto!)
                      : null,
                  child: _userPhoto == null || _userPhoto!.isEmpty
                      ? Icon(Icons.person, size: 80, color: Colors.white)
                      : null,
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16,),
                      Text("Name       : $_userName", style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 16,),
                      Text("Email        : $_userEmail", style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 16,),
                      Text("Specialization: $_specialization", style: TextStyle(fontSize: 20)),

                      SizedBox(height: 150),
                      Center(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.black),
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                          ),
                          onPressed: () {
                            SessionDoctor.clearSession();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Userselection()),
                            );
                          },
                          child: Text("Log Out"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
