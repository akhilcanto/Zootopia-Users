
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zootopia/Users/Models/user_Model.dart';
import 'package:zootopia/Users/Session.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User
  Future<String?> registerUser(String name, String email, String password,String phone, String? imageUrl) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        imageUrl: imageUrl ?? "",
      );

      await _firestore.collection("Users").doc(user.uid).set(user.toMap());

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }


  // Login User
  Future<String?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userID =userCredential.user!.uid;

      // Check if user exists in Firestore
      DocumentSnapshot userDoc = await _firestore.collection("Users").doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        return "User not found in database"; // Prevents unauthorized logins
      }
      String photo = userDoc['imageUrl'] ?? ""; // image save cheyan anu session ayittu

      await SessionUser.saveSession(email, userID,photo);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }


  // Logout User
  // Future<void> logoutUser() async {
  //   await _auth.signOut();
  // }

//pet details getting
  static Future<Map<String, dynamic>?> getPetsDetails() async{
    Map<String, String?> sessionData = await SessionUser.getSession(); // Fetch from SharedPreferences
    String? ownerID = sessionData['uid'];

    if (ownerID==null)
    {
      return null;
    }

    try{
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Pets details')
          .where('ownerID',isEqualTo: ownerID)
          .limit(0)
          .get();
      if(snapshot.docs.isNotEmpty){
        return snapshot.docs.first.data() as Map<String, dynamic>;
      }else{
        return null;
      }
    }
    catch(e){
      print("Error fetching Pet details: $e");
      return null;
    }
  }


}