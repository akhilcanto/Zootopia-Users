import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zootopia/Doctor/Function_Doctor/doc_Appbar.dart';

class LeavePage extends StatefulWidget {
  final String hospitalId;

  LeavePage({required this.hospitalId});
  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DocAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: [
                _buildFeatureTile(context, Icons.calendar_today, 'Leave Records', Leave_Requests_HIstory(hospitalId: widget.hospitalId)),
                _buildFeatureTile(context, Icons.calendar_today, 'Request Leave', DoctorMarkLeave(hospitalId: widget.hospitalId)),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(BuildContext context, IconData icon, String title, Widget route) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => route,)),
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.black),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}



class DoctorMarkLeave extends StatefulWidget {
  final String hospitalId;

  DoctorMarkLeave({required this.hospitalId});

  @override
  _DoctorMarkLeaveState createState() => _DoctorMarkLeaveState();
}

class _DoctorMarkLeaveState extends State<DoctorMarkLeave> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Set<DateTime> selectedDates = {};
  bool isLoading = false;

  Future<void> submitLeaveRequest() async {
    if (selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one date")),
      );
      return;
    }

    TextEditingController reasonController = TextEditingController();

    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Leave Reason"),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(hintText: "Enter reason for leave"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Submit"),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirmed || reasonController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
    });

    String doctorId = _auth.currentUser!.uid;

    List<String> formattedDates = selectedDates
        .map((date) => DateFormat('yyyy-MM-dd').format(date))
        .toList();

    await _firestore
        .collection('Hospital')
        .doc(widget.hospitalId)
        .collection('doctors')
        .doc(doctorId)
        .collection('leaveRequests')
        .add({
      'leaveDates': formattedDates,
      'reason': reasonController.text.trim(),
      'status': 'pending',
      'requestedAt': Timestamp.now(),
      'hospitalId': widget.hospitalId,
    });



    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Leave request submitted for approval')),
    );
    setState(() {
      isLoading = false;
      selectedDates.clear();
    });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Leave_Requests_HIstory(hospitalId: widget.hospitalId),
        ),
      );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DocAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Column(
                    children: [
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime(2100),
              focusedDay: DateTime.now(),
              selectedDayPredicate: (day) {
                return selectedDates.contains(
                  DateTime(day.year, day.month, day.day),
                );
              },
              onDaySelected: (selectedDay, focusedDay) {
                final normalized = DateTime(
                  selectedDay.year,
                  selectedDay.month,
                  selectedDay.day,
                );
                setState(() {
                  if (selectedDates.contains(normalized)) {
                    selectedDates.remove(normalized);
                  } else {
                    selectedDates.add(normalized);
                  }
                });
              },
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                selectedDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitLeaveRequest,
              child: Text("Submit Leave Request"),
            )
                    ],
                  ),
          ),
    );
  }
}




class Leave_Requests_HIstory extends StatefulWidget {
  final String hospitalId;

  Leave_Requests_HIstory({required this.hospitalId});

  @override
  _Leave_Requests_HIstoryState createState() => _Leave_Requests_HIstoryState();
}

class _Leave_Requests_HIstoryState extends State<Leave_Requests_HIstory>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String doctorId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  Stream<QuerySnapshot> _getLeaveRequests(String status) {
    return FirebaseFirestore.instance
        .collection('Hospital')
        .doc(widget.hospitalId)
        .collection('doctors')
        .doc(doctorId)
        .collection('leaveRequests')
        .where('status', isEqualTo: status)
        .orderBy('requestedAt', descending: true)
        .snapshots();
  }

  Widget _buildLeaveList(Stream<QuerySnapshot> stream, String statusLabel) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No $statusLabel leave requests."));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final List dates = doc['leaveDates'];
            final String reason = doc['reason'];
            final Timestamp requestedAt = doc['requestedAt'];
            final String docId = doc.id;

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                title: Text("Dates:\n${dates.join(', \n')}"),
                subtitle: Text(
                  "Reason: $reason\nRequested on: ${DateFormat('yyyy-MM-dd HH:mm').format(requestedAt.toDate().toLocal())}",
                ),
                trailing: statusLabel == 'pending'
                    ? IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirmed = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Delete Request"),
                        content: Text("Are you sure you want to delete this leave request?"),
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          TextButton(
                            child: Text("Delete"),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await FirebaseFirestore.instance
                          .collection('Hospital')
                          .doc(widget.hospitalId)
                          .collection('doctors')
                          .doc(doctorId)
                          .collection('leaveRequests')
                          .doc(docId)
                          .delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Leave request deleted")),
                      );
                    }
                  },
                )
                    : null,
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        toolbarHeight: 70,
        title: Image.asset('asset/Doctor/DocAppbar_black_bg.png', height: 30),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Selected tab text color
          unselectedLabelColor: Colors.white70, // Unselected tab text color (optional)
          indicatorColor: Colors.white, // Tab underline color
          tabs: [
            Tab(text: "Pending"),
            Tab(text: "Approved"),
            Tab(text: "Rejected"),
          ],
        ),

      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaveList(_getLeaveRequests('pending'), 'pending'),
          _buildLeaveList(_getLeaveRequests('approved'), 'approved'),
          _buildLeaveList(_getLeaveRequests('rejected'), 'rejected'),
        ],
      ),
    );
  }
}
