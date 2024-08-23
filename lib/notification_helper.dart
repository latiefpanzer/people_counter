import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  static init() {
    _notification.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));
  }

  static Future<void> scheduledNotification(String title, String body) async {
    var androidDetails = const AndroidNotificationDetails(
      'Important_notifications',
      'My Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    var iosDetails = const DarwinNotificationDetails();

    var notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notification.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}
