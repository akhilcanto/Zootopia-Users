import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zootopia/Starting/splass.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // vacination
  await AndroidAlarmManager.initialize();

  await AwesomeNotifications().initialize(
    null, // Use default notification icon
    [
      NotificationChannel(
        channelKey: 'vaccination_channel',
        channelName: 'Vaccination Reminders', 
        channelDescription: 'Notifications for pet vaccinations',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        playSound: true,
      )
    ],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zootopia',

      home: Splass(),
    );
  }
}

