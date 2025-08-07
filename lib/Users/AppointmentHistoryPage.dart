import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:zootopia/Users/ChatScreen.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class AppointmentHistoryPage extends StatefulWidget {
  final String petID;

  AppointmentHistoryPage({super.key, required this.petID});

  @override
  State<AppointmentHistoryPage> createState() => _AppointmentHistoryPageState();
}

class _AppointmentHistoryPageState extends State<AppointmentHistoryPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  late Future<List<Map<String, dynamic>>> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = fetchAppointments();
  }

  Future<List<Map<String, dynamic>>> fetchAppointments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .where('petId', isEqualTo: widget.petID)
          .get();

      List<Map<String, dynamic>> enrichedAppointments = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        String hospitalName = 'Unknown Hospital';
        if (data['hospitalId'] != null) {
          final hospitalSnap = await FirebaseFirestore.instance
              .collection('Hospital')
              .doc(data['hospitalId'])
              .get();
          hospitalName = hospitalSnap.data()?['hospitalname'] ?? hospitalName;
        }

        String doctorName = 'Unknown Doctor';
        if (data['doctorId'] != null) {
          final doctorSnap = await FirebaseFirestore.instance
              .collection('Doctors')
              .doc(data['doctorId'])
              .get();
          doctorName = doctorSnap.data()?['doctorname'] ?? doctorName;
        }

        enrichedAppointments.add({
          ...data,
          'hospitalName': hospitalName,
          'doctorName': doctorName,
        });
      }

      // ✅ Sort by timestamp descending (latest first)
      enrichedAppointments.sort((a, b) {
        final aTime = a['timestamp'] as Timestamp?;
        final bTime = b['timestamp'] as Timestamp?;
        return bTime!.compareTo(aTime!);
      });

      return enrichedAppointments;
    } catch (e) {
      print("Error fetching appointments: $e");
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:zootopiaAppBar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _appointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong."));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No appointments found."));
          }

          final appointments = snapshot.data!;
          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appt = appointments[index];
              final formattedTimestamp = appt['timestamp'] != null
                  ? DateFormat('yyyy-MM-dd – hh:mm a').format(
                (appt['timestamp'] as Timestamp).toDate(),
              )
                  : 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text("Date: ${appt['date'] ?? 'N/A'}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Slot Number: ${appt['slotNumber']?.toString() ?? 'N/A'}"),
                      Text("Doctor: ${appt['doctorName']}"),
                      Text("Hospital: ${appt['hospitalName']}"),
                      Text("Booked on: $formattedTimestamp"),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(appt['doctorId'],appt['doctorName'],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat),
                        label:  Text("Chat with Dr. ${appt['doctorName']}"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              );

            },
          );
        },
      ),
    );
  }
}
