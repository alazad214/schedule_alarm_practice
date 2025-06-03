import 'package:alarm/alarm.dart';
import 'package:alarm_app/prayer_alarm/views/prayer_alarm_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'helper/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final NotificationHelper notificationService = NotificationHelper();
  await notificationService.initialize();
  await Alarm.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Notification App',
      debugShowCheckedModeBanner: false,
      home: PrayerAlarmScreen(),
    );
  }
}
