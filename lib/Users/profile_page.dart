import 'package:flutter/material.dart';
import 'package:zootopia/Starting/userSelection.dart';
import 'package:zootopia/Users/Login_Page.dart';
import 'package:zootopia/Users/Session.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userName;
  String? _userEmail;
  String? _userPhoto;
  String?  _userphone;
  bool _isLoading = true; // Added loading state

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    Map<String, dynamic>? userDetails = await SessionUser.getUserDetails();
    Map<String, String?> sessionData = await SessionUser.getSession(); // Fetch from SharedPreferences

    setState(() {
      _userName = userDetails?['name'] ?? "Unknown User";
      _userEmail = userDetails?['email'] ?? "No Email Found";
      _userPhoto =sessionData['imageUrl'];
      _userphone = userDetails?['phoneNo']??"Loading";
      _isLoading = false; // Set loading to false after fetching data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zootopiaAppBar(),
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
                      Text("Phone No : $_userphone", style: TextStyle(fontSize: 20)),

                      SizedBox(height: 150),
                      Center(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.black),
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                          ),
                          onPressed: () {
                            SessionUser.clearSession();
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
