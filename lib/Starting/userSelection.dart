import 'package:flutter/material.dart';
import 'package:zootopia/Hospital/LoginHospital.dart';
import 'package:zootopia/Users/Login_Page.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class Userselection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Matches your sketch's black background
      appBar: zootopiaAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOption(
                  icon: Icons.local_hospital,
                  label: 'Z Care+',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginHospital(),));
                  },
                ),
                SizedBox(width: 20),
                _buildOption(
                  icon: Icons.pets,
                  label: 'Zootopia',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white, // Mimics your sketch's color theme
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: Colors.black),
            SizedBox(height: 10),
            Text(label, style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
