import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';
import 'package:zootopia/Users/loaction%20home%20picker.dart';

class TrackLocation extends StatefulWidget {
 TrackLocation({super.key, required this.PetID});

  final String PetID;

  @override
  _TrackLocationState createState() => _TrackLocationState();
}

class _TrackLocationState extends State<TrackLocation> {


  double? latitude;
  double? longitude;
  String geofenceStatus = "Loading...";
  String notificationMessage = "No notifications yet";
  String previousGeofenceStatus = "";
  //
  // final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  // FlutterLocalNotificationsPlugin();

  DatabaseReference? _databaseRef;

  @override
  void initState() {
    super.initState();
    _databaseRef = FirebaseDatabase.instance
        .ref()
        .child("pets/${widget.PetID}/gps/latest");

    _initializeNotifications();
    _fetchRealtimeData();
    _setupFirebaseMessaging();
  }


  /// Initializes local notifications
  void _initializeNotifications() {
    // const AndroidInitializationSettings androidSettings =
    // AndroidInitializationSettings('@mipmap/ic_launcher');
    // const InitializationSettings initSettings =
    // InitializationSettings(android: androidSettings);
    //
    // _localNotificationsPlugin.initialize(initSettings,
    //     onDidReceiveNotificationResponse: (NotificationResponse response) {
    //       debugPrint("🔔 Notification Clicked: ${response.payload}");
    //     });
  }

  /// Fetches real-time GPS data & geofence status from Firebase
  void _fetchRealtimeData() {
    _databaseRef?.onValue.listen((event) {
      if (event.snapshot.exists) {
        final dynamic rawData = event.snapshot.value;

        if (rawData is Map<dynamic, dynamic>) {
          final newStatus = rawData["geofence_status"] ?? "Unknown";

          setState(() {
            latitude = (rawData["latitude"] ?? 0.0).toDouble();
            longitude = (rawData["longitude"] ?? 0.0).toDouble();
            geofenceStatus = newStatus;
          });

          /// 🚀 Check if status has changed
          if (newStatus != previousGeofenceStatus) {
            previousGeofenceStatus = newStatus;

            if (newStatus == "OUTSIDE_GEOFENCE") {
              _sendLocalNotification("🚨 Pet Left Safe Zone!",
                  "Current Location: $latitude, $longitude");
            } else if (newStatus == "INSIDE_GEOFENCE") {
              // _sendLocalNotification("✅ Pet is Safe", "Your pet is inside the geofence.");
              print("Pet is inside");
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Your pet is inside the geofence."),
                duration: Duration(seconds: 2),
              ));
            }
          }
        } else {
          debugPrint("⚠️ Unexpected data format from Firebase.");
        }
      }
    }, onError: (error) {
      debugPrint("🔥 Error fetching data: $error");
      setState(() {
        geofenceStatus = "Error fetching data";
      });
    });
  }

  /// Sets up Firebase Cloud Messaging (FCM) for notifications
  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        setState(() {
          notificationMessage =
              message.notification!.body ?? "No message received";
        });

        _sendLocalNotification(message.notification!.title ?? "Notification",
            message.notification!.body ?? "New message received");
      }
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null && message.notification != null) {
        setState(() {
          notificationMessage =
              message.notification!.body ?? "No message received";
        });

        _sendLocalNotification(message.notification!.title ?? "Notification",
            message.notification!.body ?? "New message received");
      }
    });
  }

  /// Sends a local notification
  Future<void> _sendLocalNotification(String title, String body) async {
    // const AndroidNotificationDetails androidDetails =
    // AndroidNotificationDetails(
    //   'high_importance_channel',
    //   'High Importance Notifications',
    //   importance: Importance.high,
    //   priority: Priority.high,
    //   playSound: true,
    // );
    //
    // const NotificationDetails details =
    // NotificationDetails(android: androidDetails);
    //
    // await _localNotificationsPlugin.show(
    //   title.hashCode,
    //   title,
    //   body,
    //   details,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text("Track your pet",
      //       style:
      //       GoogleFonts.aboreto(fontSize: 16, fontWeight: FontWeight.bold)),
      //   backgroundColor: Colors.lightBlue[200],
      //   foregroundColor: Colors.white,
      // ),
      appBar: zootopiaAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity, // Makes the Card take full width

                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text("📍 Current Location",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown[900])),
                        SizedBox(height: 10),
                        latitude == null || longitude == null
                            ? CircularProgressIndicator()
                            : Column(
                          children: [
                            Text("Latitude: $latitude",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500)),
                            Text("Longitude: $longitude",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500)),

                        SizedBox(height: 20,),
                        ElevatedButton(
                          onPressed: () async {
                            String url =
                                "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
                            final Uri uri = Uri.parse(url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          child: Text("View Location On Map"),
                        )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // 📡 Geofence Status Card
              Container(
                width: double.infinity, // Makes the Card take full width
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text("📡 Geofence Status",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown[900])),
                        SizedBox(height: 10),
                        geofenceStatus == "Loading..."
                            ? CircularProgressIndicator()
                            : Text(
                          geofenceStatus,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: geofenceStatus == "OUTSIDE_GEOFENCE"
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              latitude == null || longitude == null
                  ? Center(child: Text('Searching traker'),):
                ElevatedButton( onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetHomeLocationScreen(petId: widget.PetID),
                    ),
                  );
                }, child: Text("Set Home Location")),

              // 🔔 Last Notification Card
              Container(
                width: double.infinity, // Makes the Card take full width

                // child: Card(
                //   color: Colors.white,
                //   shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(15)),
                //   elevation: 5,
                //   child: Padding(
                //     padding: const EdgeInsets.all(16.0),
                //     child: Column(
                //       children: [
                //         Text("🔔 Last Notification",
                //             style: TextStyle(
                //                 fontSize: 22,
                //                 fontWeight: FontWeight.bold,
                //                 color: Colors.brown[900])),
                //         SizedBox(height: 10),
                //         notificationMessage == "No notifications yet"
                //             ? Text("No notifications yet",
                //                 style: TextStyle(
                //                     fontSize: 16,
                //                     fontStyle: FontStyle.italic,
                //                     color: Colors.grey))
                //             : Text(notificationMessage,
                //                 textAlign: TextAlign.center,
                //                 style: TextStyle(
                //                     fontSize: 16, fontWeight: FontWeight.w500)),
                //       ],
                //     ),
                //   ),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
