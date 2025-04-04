import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'features/home_screen.dart';
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
    return MaterialApp(
      title: 'Notification App',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
