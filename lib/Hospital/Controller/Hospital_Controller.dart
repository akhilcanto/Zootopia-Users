import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zootopia/Hospital/Models/Hospital_Model.dart';
import 'package:zootopia/Hospital/session_hospital.dart';



class hospitalController{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =FirebaseFirestore.instance;

  // register hospital
  Future<String?> registerHospital(String hospitalname, String email, String password, String? imageUrl, String state, String district, String city, String description, String phone) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      HospitalModel hospital = HospitalModel(
        uid: userCredential.user!.uid,
        hospitalname: hospitalname,
        email: email,
        imageUrl: imageUrl ?? "",
        state: state,
        district: district,
        city: city,
        description: description,
        phone: phone,
      );

      await _firestore.collection("Hospital").doc(hospital.uid).set(hospital.toMap());

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }


  // Login hospital
  Future<String?> loginHospital(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userID =userCredential.user!.uid;

      // Check if user exists in Firestore

      DocumentSnapshot userDoc = await _firestore.collection("Hospital").doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        return "Hospital not found in database"; // Prevents unauthorized logins
      }
      String photo = userDoc['imageUrl'] ?? ""; // image save cheyan anu session ayittu

      await SessionHospital.saveSession(email, userID ,photo);

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