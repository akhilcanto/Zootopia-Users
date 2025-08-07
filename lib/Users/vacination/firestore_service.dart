import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> addVaccination(String petId, String vaccineName, DateTime dueDate) async {
    await _db.collection('pets').doc(petId).collection('vaccinations').add({
      'vaccineName': vaccineName,
      'dueDate': dueDate.toIso8601String(),
      'status': 'pending', // default status
    });
  }

  static Future<void> deleteVaccination(String petId, String docId) async {
    await _db.collection('pets').doc(petId).collection('vaccinations').doc(docId).delete();
  }

  static Future<void> completeVaccination(String petId, String docId, Map<String, dynamic> data) async {
    // Move to completed_vaccinations collection
    await _db.collection('pets').doc(petId).collection('completed_vaccinations').add(data);
    // Delete from vaccinations collection
    await _db.collection('pets').doc(petId).collection('vaccinations').doc(docId).delete();
  }

  static Stream<QuerySnapshot> getVaccinations(String petId) {
    return _db.collection('pets').doc(petId).collection('vaccinations').snapshots();
  }

  static Stream<QuerySnapshot> getCompletedVaccinations(String petId) {
    return _db.collection('pets').doc(petId).collection('completed_vaccinations').snapshots();
  }
}
