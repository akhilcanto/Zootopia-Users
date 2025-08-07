import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>?> getPetDetails(String uid) async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Pets_details')
        .where('petID', isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  } catch (e) {
    print("Error fetching user details: $e");
    return null;
  }
}

Future<void> deletePet(String petID) async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Pets_details')
        .where('petID', isEqualTo: petID)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      DocumentReference petRef = snapshot.docs.first.reference;

      // Recursively delete all subcollections
      await deleteSubcollections(petRef);

      // Now delete the pet document itself
      await petRef.delete();
      print("Pet and all related data deleted successfully");
    } else {
      print("Pet not found");
    }
  } catch (e) {
    print("Error deleting pet: $e");
  }
}

Future<void> deleteSubcollections(DocumentReference parentRef) async {
  try {
    // Get all subcollections inside the pet document cheyan
    List<String> subcollections = ["medicalRecords"/*, "Vaccinations", "Appointments"*/]; // Add all known subcollections cheyan

    for (String subcollection in subcollections) {
      QuerySnapshot subSnapshot = await parentRef.collection(subcollection).get();

      for (QueryDocumentSnapshot doc in subSnapshot.docs) {
        await doc.reference.delete(); // Delete each document inside subcollection
      }
    }
  } catch (e) {
    print("Error deleting subcollections: $e");
  }
}




