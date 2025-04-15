import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';

class NotificationHelper {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // const DarwinInitializationSettings iosSettings =
    //     DarwinInitializationSettings(
    //       requestSoundPermission: true,
    //       requestAlertPermission: true,
    //       requestBadgePermission: true,
    //     );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _requestIOSPermissions();
    await _requestAndroidPermissions();
  }

  Future<void> _requestIOSPermissions() async {
    final bool? granted =
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions();

    if (granted == true) {
      log("Notification permissions granted on iOS.");
    } else {
      log("Notification permissions not granted on iOS.");
    }
  }

  Future<void> _requestAndroidPermissions() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        log("Notification permissions granted on Android.");
      } else {
        log("Notification permissions not granted on Android.");
      }
    }
  }

  Future<void> requestExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      if (status.isGranted) {
        log("Exact alarm permission granted.");
      } else {
        log("Exact alarm permission denied.");
      }
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz.setLocalLocation(tz.local);
  }

  Future<void> showNotification(int id, String title, String body) async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'alarm_channel',
        'Alarm Notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
        vibrationPattern: Int64List.fromList([0, 500, 1000, 500]),
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime selectedDate,
    TimeOfDay selectedTime,
  ) async {
    await _configureLocalTimeZone(); // Ensure the time zone is set up correctly
    await requestExactAlarmPermission();

    // Combine the selected date and time into a DateTime object

    final DateTime combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final tz.TZDateTime scheduledDateTime = tz.TZDateTime.from(
      combinedDateTime,
      tz.local,
    );

    log("Scheduling notification at: $scheduledDateTime");

    // Setting up notification details
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'alarm_channel',
        'Alarm Notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
      ),
    );

    // Schedule the notification using the correct time and local time zone
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'payload',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
