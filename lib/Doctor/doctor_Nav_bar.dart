import 'package:flutter/material.dart';
import 'package:zootopia/Doctor/ChatListing_doctor.dart';
import 'package:zootopia/Doctor/add_hospitals.dart';
import 'package:zootopia/Doctor/chat_page_Doctor.dart';
import 'package:zootopia/Doctor/doctorHome.dart';
import 'package:zootopia/Doctor/doctor_profile.dart';
import 'package:zootopia/Doctor/view_Hospital_Doctor.dart';

class Doctor_Nav_Bar extends StatefulWidget {
  final int initialIndex;

  const Doctor_Nav_Bar({super.key, this.initialIndex = 0});

  @override
  State<Doctor_Nav_Bar> createState() => _BottomnavBarState();
}

class _BottomnavBarState extends State<Doctor_Nav_Bar> {
  late int _selectedindex;

  @override
  void initState() {
    super.initState();
    _selectedindex = widget.initialIndex; // Set the initial index
  }

  final List<Widget> _pages = [
    DoctorHome(),
    ViewHospitalDoctor(),
    ChatList_Doctor(),
    // HospitalListScreen(),
    DoctorProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedindex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedindex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white60,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital), label: 'My Hospitals'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          // BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Hospitals'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
