import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:zootopia/Users/ChatScreen.dart';
import 'package:zootopia/Users/bottomnavbar.dart';

class BookAppointmentPage extends StatefulWidget {
  final String doctorName;
  final String doctorId;
  final String hospitalId;
  final String workingTime;
  final List workingDays;

  const BookAppointmentPage({
    required this.doctorId,
    required this.hospitalId,
    required this.doctorName,
    required this.workingTime,
    required this.workingDays,
    Key? key,
  }) : super(key: key);

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  DateTime? selectedDate;
  String? selectedPetId;
  String? selectedTimeSlot;
  List<Map<String, dynamic>> pets = [];
  List<String> availableTimeSlots = [];
  bool isDoctorOnLeave = false;

  @override
  void initState() {
    super.initState();
    fetchUserPets();
  }

  Future<void> fetchUserPets() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot petSnapshot = await FirebaseFirestore.instance
        .collection('Pets_details')
        .where('ownerID', isEqualTo: userId)
        .get();

    setState(() {
      pets = petSnapshot.docs.map((doc) => {
        "id": doc.id,
        "name": doc["petName"] ?? "Unknown Pet"
      }).toList();
    });
  }
  Future<void> checkDoctorLeave(DateTime date) async {
    DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
        .collection('Hospital')
        .doc(widget.hospitalId)
        .collection('doctors')
        .doc(widget.doctorId)
        .get();

    var leaveData = doctorDoc['leave']; // Should be List<String>

    List<String> leaveDateStrings = [];

    if (leaveData is String) {
      leaveDateStrings = [leaveData];
    } else if (leaveData is List) {
      leaveDateStrings = List<String>.from(leaveData); // cast safely
    }

    bool isOnLeave = leaveDateStrings.any((leaveDateStr) {
      DateTime leaveDate = DateTime.parse(leaveDateStr); // parses yyyy-MM-dd
      return leaveDate.year == date.year &&
          leaveDate.month == date.month &&
          leaveDate.day == date.day;
    });

    setState(() {
      isDoctorOnLeave = isOnLeave;
      availableTimeSlots = isOnLeave ? [] : availableTimeSlots; // just placeholder here
    });

    if (!isOnLeave) {
      generateAvailableTimeSlots(); // separately call this function
    }
  }



  void selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (pickedDate != null &&
        widget.workingDays.contains(_getDayOfWeek(pickedDate))) {
      setState(() {
        selectedDate = pickedDate;
        selectedTimeSlot = null; // Reset selected time slot
      });
      await checkDoctorLeave(pickedDate);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Doctor is not available on this day.")),
      );
    }
  }

  void generateAvailableTimeSlots() {
    RegExp timeRegex = RegExp(r'(\d{1,2}:\d{2} [APM]{2}) - (\d{1,2}:\d{2} [APM]{2})');
    Match? match = timeRegex.firstMatch(widget.workingTime);

    if (match != null) {
      String startTimeStr = match.group(1)!;
      String endTimeStr = match.group(2)!;

      DateTime startTime = _parseTime(startTimeStr);
      DateTime endTime = _parseTime(endTimeStr);

      List<String> slots = [];
      DateTime currentTime = startTime;

      while (currentTime.isBefore(endTime)) {
        slots.add(_formatTime(currentTime));
        currentTime = currentTime.add(Duration(minutes: 30)); // 30-minute slots
      }

      setState(() {
        availableTimeSlots = slots;
      });
    }
  }

  DateTime _parseTime(String timeStr) {
    return DateFormat("h:mm a").parse(timeStr);
  }

  String _formatTime(DateTime time) {
    return DateFormat("h:mm a").format(time);
  }
  Future<int> getBookedCount(String dateStr) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: widget.doctorId)
        .where('hospitalId', isEqualTo: widget.hospitalId)
        .where('date', isEqualTo: dateStr)
        .get();

    return snapshot.docs.length;
  }

  void bookAppointment() async {
    if (selectedDate == null || selectedPetId == null ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select all required fields")),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);

    // ✅ Check if appointment already exists for same user, doctor, date, and pet
    final existingAppointments = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: widget.doctorId)
        .where('userId', isEqualTo: userId)
        .where('petId', isEqualTo: selectedPetId)
        .where('date', isEqualTo: dateStr)
        .get();

    if (existingAppointments.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You already booked an appointment for this pet on this date.")),
      );
      return;
    }

    final slotDocRef = FirebaseFirestore.instance
        .collection('Hospital')
        .doc(widget.hospitalId)
        .collection('doctors')
        .doc(widget.doctorId)
        .collection('slotAvailability')
        .doc(dateStr);

    DocumentSnapshot slotDoc = await slotDocRef.get();

    int slotsLeft;

    if (slotDoc.exists) {
      slotsLeft = slotDoc['slotsLeft'];
    } else {
      // Fetch default slots from doctor document
      final doctorDoc = await FirebaseFirestore.instance
          .collection('Hospital')
          .doc(widget.hospitalId)
          .collection('doctors')
          .doc(widget.doctorId)
          .get();

      final defaultSlots = doctorDoc['defaultSchedule']['timeSlots'][0]['slots'];
      slotsLeft = defaultSlots;

      await slotDocRef.set({'slotsLeft': defaultSlots});
    }

    if (slotsLeft <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No available slots on this date")),
      );
      return;
    }

    final totalSlots = slotDoc.exists
        ? slotDoc['slotsLeft'] + await getBookedCount(dateStr)
        : slotsLeft;

    final currentBooked = totalSlots - slotsLeft;
    final slotNumber = currentBooked + 1;

    await FirebaseFirestore.instance.collection('appointments').add({
      'doctorId': widget.doctorId,
      'hospitalId': widget.hospitalId,
      'userId': userId,
      'petId': selectedPetId,
      'date': dateStr,
      'time': selectedTimeSlot,
      'slotNumber': slotNumber,
      'workingTime': widget.workingTime,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await slotDocRef.update({'slotsLeft': FieldValue.increment(-1)});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Appointment booked successfully!")),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Bottomnavbar(initialIndex: 0),
      ),
          (route) => false,
    );  }


  String _getDayOfWeek(DateTime date) {
    return [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ][date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Book Appointment with ${widget.doctorName}",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white), // Back icon color
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedPetId,
              hint: Text("Select Pet"),
              onChanged: (value) {
                setState(() {
                  selectedPetId = value;
                });
              },
              items: pets
                  .map<DropdownMenuItem<String>>((pet) => DropdownMenuItem(
                value: pet["id"],
                child: Text(pet["name"] ?? "Unknown Pet"),
              ))
                  .toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => selectDate(context),
              child: Text(selectedDate == null
                  ? "Select Date"
                  : "Selected: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}"),
            ),
            SizedBox(height: 20),
            if (selectedDate != null)
              isDoctorOnLeave
                  ? Text("Doctor is on leave on this date", style: TextStyle(color: Colors.red))
                  : ElevatedButton(
              onPressed: bookAppointment,
              child: Text("Book Appointment"),
            ),

          ],
        ),
      ),
    );
  }
}
