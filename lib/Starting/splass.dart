import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:zootopia/Doctor/doctorHome.dart';
import 'package:zootopia/Doctor/doctor_Nav_bar.dart';
import 'package:zootopia/Doctor/session_Doctor.dart';
import 'package:zootopia/Hospital/Hospital_home.dart';
import 'package:zootopia/Hospital/session_hospital.dart';
import 'package:zootopia/Starting/userSelection.dart';
import 'package:zootopia/Users/Session.dart';
import 'package:zootopia/Users/bottomnavbar.dart';

class Splass extends StatefulWidget {
  const Splass({super.key});

  @override
  State<Splass> createState() => _SplassState();
}

class _SplassState extends State<Splass> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }
  Future<void> _checkSession() async {
    final userSession = await SessionUser.getSession();
    final hospitalSession = await SessionHospital.getSession();
    final doctorSession = await SessionDoctor.getSession();


    debugPrint("User Session: $userSession");
    debugPrint("Hospital Session: $hospitalSession");

    final String? userUid = userSession['uid'];
    final String? hospitalUid = hospitalSession['uid'];
    final String? hospitalMode = hospitalSession['mode']; // **Added check for mode**
    final String? doctorUid = hospitalSession['uid'];
    final String? doctorMode = hospitalSession['mode'];

    await Future.delayed(const Duration(seconds: 3));

    if (hospitalUid != null && hospitalMode == "hospital") { // **Fix: Ensures hospital mode**
      debugPrint("Navigating to HospitalHome()");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HospitalHome()),
      );
    }
    else if (hospitalUid != null && hospitalMode == "doctor") { // **Fix: Ensures hospital mode**
      debugPrint("Navigating to doctor()");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Doctor_Nav_Bar()),
      );
    }else if (userUid != null&& hospitalMode == "user") {
      debugPrint("Navigating to Bottomnavbar()");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  Bottomnavbar()),
      );
    } else {
      debugPrint("Navigating to Userselection()");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Userselection()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset("asset/Animation - 1737646946039.json"),
      ),
    );
  }
}
