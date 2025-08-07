import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static Future<void> showNotification(String vaccineName, DateTime dueDate) async {
    // Initialize timezone
    tz.initializeTimeZones();
    final location = tz.getLocation('Asia/Kolkata'); // Change based on your timezone

    // Schedule 1 day before at 8 AM
    DateTime dayBefore = dueDate.subtract(const Duration(days: 1));
    tz.TZDateTime scheduledDate1 = tz.TZDateTime(
      location,
      dayBefore.year,
      dayBefore.month,
      dayBefore.day,
      8, // 8 AM notification
      0,
      0,
    );

    // Schedule 3 hours before the due time
    DateTime threeHoursBefore = dueDate.subtract(const Duration(hours: 3));
    tz.TZDateTime scheduledDate2 = tz.TZDateTime.from(threeHoursBefore, location);

    // Create first notification (1 day before)
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: dueDate.millisecondsSinceEpoch ~/ 1000, // Unique ID
        channelKey: 'vaccination_channel',
        title: 'Vaccination Reminder',
        body: 'Tomorrow is the $vaccineName vaccine for your pet!',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: scheduledDate1.year,
        month: scheduledDate1.month,
        day: scheduledDate1.day,
        hour: scheduledDate1.hour,
        minute: scheduledDate1.minute,
        second: 0,
        timeZone: tz.local.name,
        repeats: false,
      ),
    );

    // Create second notification (3 hours before)
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: (dueDate.millisecondsSinceEpoch ~/ 1000) + 1, // Unique ID
        channelKey: 'vaccination_channel',
        title: 'Upcoming Vaccination',
        body: 'Your pet’s $vaccineName vaccine is in 3 hours!',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: scheduledDate2.year,
        month: scheduledDate2.month,
        day: scheduledDate2.day,
        hour: scheduledDate2.hour,
        minute: scheduledDate2.minute,
        second: 0,
        timeZone: tz.local.name,
        repeats: false,
      ),
    );
  }
}
