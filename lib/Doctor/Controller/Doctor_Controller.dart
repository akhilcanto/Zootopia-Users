
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zootopia/Doctor/Model/Doctor_Model.dart';
import 'package:zootopia/Doctor/session_Doctor.dart';

class doctorController{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =FirebaseFirestore.instance;

  // register hospital
  Future<String?> registerDoctor(String doctorname, String email, String password, String? imageUrl,  String specialization) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      DoctorModel doctor = DoctorModel(
        uid: userCredential.user!.uid,
        doctorname: doctorname,
        email: email,
        imageUrl: imageUrl ?? "",
        specialization: specialization,
      );

      await _firestore.collection("Doctors").doc(doctor.uid).set(doctor.toMap());

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }


  // Login hospital
  Future<String?> loginDoctor(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userID =userCredential.user!.uid;

      // Check if user exists in Firestore

      DocumentSnapshot userDoc = await _firestore.collection("Doctors").doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        return "Doctor not found in database"; // Prevents unauthorized logins
      }
      String photo = userDoc['imageUrl'] ?? ""; // image save cheyan anu session ayittu

      await SessionDoctor.saveSession(email, userID ,photo);

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  Future<void> sendPasswordResetLink(String email) async {
    try{
      await _auth.sendPasswordResetEmail(email: email);
    }
    catch (e)
    {
      print(e.toString());
    }
  }

}