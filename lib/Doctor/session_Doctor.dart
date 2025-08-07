import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionDoctor{
  static const String _emailKey ='email';
  static const String _uuidKey = 'uid';
  static const String _modeKey= 'mode';
  static const String _photoKey = "image";

  // email and Uuid save cheyan
  static Future<void> saveSession(String email, String uuid , String photo) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_uuidKey, uuid);
    await prefs.setString(_photoKey, photo);
    await prefs.setString(_modeKey, "doctor"); // **Fix: Save mode**

  }


  // Get session data
  static Future<Map<String, String?>> getSession() async{
    SharedPreferences prefs =await SharedPreferences.getInstance();
    return{
      'email' : prefs.getString(_emailKey),
      'uid' : prefs.getString(_uuidKey),
      'mode' : prefs.getString(_modeKey),
      'imageUrl' : prefs.getString(_photoKey),
    };
  }


  // get Hospital details from firestore using email
  static Future<Map<String, dynamic>?> getDoctorDetails() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString(_uuidKey);

    if (uuid==null)
    {
      return null;
    }

    try{
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .where('uid',isEqualTo: uuid)
          .limit(1)
          .get();
      if(snapshot.docs.isNotEmpty){
        return snapshot.docs.first.data() as Map<String, dynamic>;
      }else{
        return null;
      }
    }
    catch(e){
      print("Error fetching user details: $e");
      return null;
    }
  }

  static Future<void> clearSession() async{
    final FirebaseAuth _auth = FirebaseAuth.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_uuidKey);
    await prefs.remove(_photoKey);
    await _auth.signOut();
  }
}

