import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class VaccinationNotifications extends StatelessWidget {
  const VaccinationNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final DateTime now = DateTime.now();
    final DateTime fiveDaysLater = now.add(const Duration(days: 5));

    return Scaffold(
      appBar: zootopiaAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('vaccinations')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No upcoming vaccinations.'));
          }

          final upcomingVaccinations = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final DateTime dueDate = DateTime.parse(data['dueDate']);
            final String status = data['status'] ?? 'pending';
            return dueDate.isAfter(now) &&
                dueDate.isBefore(fiveDaysLater) &&
                status != 'completed'; // Exclude completed vaccinations
          }).toList();

          if (upcomingVaccinations.isEmpty) {
            return const Center(child: Text('No vaccinations due in next 5 days.'));
          }

          return ListView.builder(
            itemCount: upcomingVaccinations.length,
            itemBuilder: (context, index) {
              final data = upcomingVaccinations[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.orange),
                  title: Text(data['vaccineName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Pet name: ${data['petName']}\nDue on: ${data['dueDate'].split('T')[0]}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
