import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zootopia/Users/Appoinment.dart';
import 'package:zootopia/Users/ChatScreen.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class DoctorListScreen extends StatefulWidget {
  final String hospitalId;

  DoctorListScreen({required this.hospitalId});

  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> doctors = [];

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    setState(() => isLoading = true);

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Hospital")
          .doc(widget.hospitalId)
          .collection("doctors")
          .get();

      List<Map<String, dynamic>> doctorList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Extract schedule details safely
        Map<String, dynamic>? scheduleData = data.containsKey("defaultSchedule")
            ? data["defaultSchedule"] as Map<String, dynamic>?
            : null;

        return {
          "doctorId": doc.id,
          "doctorname": data["doctorname"]?.toString() ?? "Unknown",
          "specialization":
              data["specialization"]?.toString() ?? "Not specified",
          "startTime": scheduleData?["startTime"]?.toString() ?? "Not Set",
          "endTime": scheduleData?["endTime"]?.toString() ?? "Not Set",
          "workingDays": scheduleData?["workingDays"] ?? [],
          "imageUrl": data["imageUrl"]?.toString() ?? "",
        };
      }).toList();

      setState(() {
        doctors = doctorList;
      });
    } catch (e) {
      print("Error fetching doctors: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void bookAppointment(String doctorId, String workingTime, List workingDays , String doctorName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentPage(
          hospitalId: widget.hospitalId,
          doctorId: doctorId,
          doctorName: doctorName,
          workingTime: workingTime, // Pass working time instead of doctor name
          workingDays: workingDays,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zootopiaAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : doctors.isEmpty
                      ? Center(child: Text("No doctors found."))
                      : ListView.builder(
                          itemCount: doctors.length,
                          itemBuilder: (context, index) {
                            var doctor = doctors[index];
                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: doctor["imageUrl"]!.isNotEmpty
                                              ? FadeInImage.assetNetwork(
                                                  placeholder:
                                                      "asset/Doctor/LoginDoc_white_bg.png",
                                                  image: doctor["imageUrl"]!,
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  imageErrorBuilder: (context,
                                                          error, stackTrace) =>
                                                      Icon(Icons.broken_image,
                                                          size: 50,
                                                          color: Colors.grey),
                                                )
                                              : Image.asset(
                                                  "asset/Doctor/LoginDoc_white_bg.png",
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                doctor['doctorname']!,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                doctor['specialization']!,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700]),
                                              ),
                                              // SizedBox(height: 5),
                                              // Text(
                                              //   "Working Hours: ${doctor['startTime']} - ${doctor['endTime']}",
                                              //   style: TextStyle(
                                              //       fontSize: 14,
                                              //       color: Colors.grey[700]),
                                              // ),
                                              SizedBox(height: 5),
                                              Text(
                                                "Available Days: ${doctor['workingDays'].join(', ')}",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.green),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: () => bookAppointment(
                                          doctor["doctorId"]!,
                                          "${doctor["startTime"]} - ${doctor["endTime"]}", // Send working time instead of name
                                          doctor["workingDays"],
                                          doctor["doctorname"]
                                        ),

                                        child: Text("Book Appointment"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
//
// class BookAppointmentScreen extends StatefulWidget {
//   final String hospitalId;
//   final String doctorId;
//   final String doctorName;
//   final List workingDays;
//
//   BookAppointmentScreen({
//     required this.hospitalId,
//     required this.doctorId,
//     required this.doctorName,
//     required this.workingDays,
//   });
//
//   @override
//   _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
// }
//
// class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
//   DateTime selectedDate = DateTime.now();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Book Appointment with ${widget.doctorName}")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text("Select an appointment date", style: TextStyle(fontSize: 18)),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () async {
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: selectedDate,
//                   firstDate: DateTime.now(),
//                   lastDate: DateTime.now().add(Duration(days: 30)),
//                 );
//
//                 if (pickedDate != null &&
//                     widget.workingDays.contains(_getDayOfWeek(pickedDate))) {
//                   setState(() {
//                     selectedDate = pickedDate;
//                   });
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                         content: Text("Doctor is not available on this day.")),
//                   );
//                 }
//               },
//               child: Text("Pick a Date"),
//             ),
//             SizedBox(height: 20),
//             Text("Selected Date: ${selectedDate.toLocal()}".split(' ')[0]),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Store appointment in Firestore (add functionality)
//                 print(
//                     "Appointment booked for ${widget.doctorName} on ${selectedDate.toLocal()}");
//               },
//               child: Text("Confirm Appointment"),
//             ),
//             SizedBox(
//               height: 25,
//             ),
//             ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ChatScreen(
//                           widget.doctorId,
//                           widget.doctorName,
//                         ),
//                       ));
//                 },
//                 child: Text("Chat with doctor"))
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _getDayOfWeek(DateTime date) {
//     return [
//       "Sunday",
//       "Monday",
//       "Tuesday",
//       "Wednesday",
//       "Thursday",
//       "Friday",
//       "Saturday"
//     ][date.weekday % 7];
//   }
// }
