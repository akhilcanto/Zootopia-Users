import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoctorTodaysAppointmentsPage extends StatefulWidget {
  @override
  _DoctorTodaysAppointmentsPageState createState() =>
      _DoctorTodaysAppointmentsPageState();
}

class _DoctorTodaysAppointmentsPageState
    extends State<DoctorTodaysAppointmentsPage> {
  DateTime selectedDate = DateTime.now();
  Map<String, String> userNameCache = {}; // Cache for user names

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<String> getUserName(String userId) async {
    if (userNameCache.containsKey(userId)) {
      return userNameCache[userId]!;
    }
    final doc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    final name = doc.data()?['name'] ?? 'Unnamed';
    userNameCache[userId] = name;
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Appointments")),
        body: Center(child: Text("User not logged in")),
      );
    }

    final String doctorId = currentUser.uid;
    final String selectedDateStr =
    DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text("Appointments"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: doctorId)
            .where('date', isEqualTo: selectedDateStr)
            .orderBy('slotNumber')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text("No appointments for this day."));

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final data = appointments[index].data() as Map<String, dynamic>;
              final userId = data['userId'];
              final petID =data['petId'];
              final slotNumber = data['slotNumber'];

              return FutureBuilder<String>(
                future: getUserName(userId),
                builder: (context, nameSnapshot) {
                  final userName =
                  nameSnapshot.connectionState == ConnectionState.done
                      ? nameSnapshot.data ?? 'Unnamed'
                      : 'Loading...';

                  return ListTile(
                    leading: Icon(Icons.person),
                    title: Text(userName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text("Slot #: $slotNumber\nPet ID : $petID"),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
