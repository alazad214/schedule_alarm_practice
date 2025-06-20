import 'dart:developer';
import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:flutter/material.dart';
import 'package:alarm_app/helper/database_helper.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final List<String> cities = ['Mecca', 'Medina', 'Cairo', 'Istanbul'];
  final List<String> prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  String? selectedCity;
  String? selectedPrayer;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  List<Map<String, dynamic>> alarms = [];

  @override
  void initState() {
    super.initState();
    loadAlarmsFromDb();
  }

  Future<void> loadAlarmsFromDb() async {
    final data = await DatabaseHelper().getAlarms();
    setState(() {
      alarms = data;
    });
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  Future<void> addAlarm() async {
    if (selectedCity != null &&
        selectedPrayer != null &&
        selectedDate != null &&
        selectedTime != null) {
      final alarmDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final newAlarm = {
        'city': selectedCity,
        'prayer': selectedPrayer,
        'date': selectedDate!.toIso8601String(),
        'time': selectedTime!.format(context),
      };

      int dbId = await DatabaseHelper().insertAlarm(newAlarm);
      await loadAlarmsFromDb();

      await Alarm.set(
        alarmSettings: AlarmSettings(
          id: dbId,
          dateTime: alarmDateTime,
          assetAudioPath: 'assets/alarm.mp3',
          loopAudio: false,
          vibrate: true,
          warningNotificationOnKill: Platform.isIOS,
          androidFullScreenIntent: true,
          volumeSettings: VolumeSettings.fade(
            volume: 0.8,
            fadeDuration: const Duration(seconds: 5),
            volumeEnforced: true,
          ),
          notificationSettings: NotificationSettings(
            title: 'Alarm for $selectedPrayer',
            body: 'It\'s time for $selectedPrayer in $selectedCity',
            stopButton: 'Stop',
            icon: 'notification_icon',
          ),
        ),
      );

      selectedCity = null;
      selectedPrayer = null;
      selectedDate = null;
      selectedTime = null;
      setState(() {});
    }
  }

  String formatDate(String date) {
    return DateTime.parse(date).toLocal().toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Prayer Alarm")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select City'),
              value: selectedCity,
              items:
                  cities
                      .map(
                        (city) =>
                            DropdownMenuItem(value: city, child: Text(city)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => selectedCity = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Prayer'),
              value: selectedPrayer,
              items:
                  prayers
                      .map(
                        (prayer) => DropdownMenuItem(
                          value: prayer,
                          child: Text(prayer),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => selectedPrayer = value),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text(
                selectedDate != null
                    ? 'Date: ${formatDate(selectedDate!.toIso8601String())}'
                    : 'Pick a date',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: pickDate,
            ),
            ListTile(
              title: Text(
                selectedTime != null
                    ? 'Time: ${selectedTime!.format(context)}'
                    : 'Pick a time',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: pickTime,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: addAlarm,
              icon: const Icon(Icons.alarm_add),
              label: const Text("Add Alarm"),
            ),
            const Divider(height: 40),
            const Text("Saved Alarms", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return Dismissible(
                  key: Key(alarm['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    await Alarm.stop(alarm['id']);
                    await DatabaseHelper().deleteAlarm(alarm['id']);
                    await loadAlarmsFromDb();
                    log("Alarm deleted");
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('${alarm['prayer']} in ${alarm['city']}'),
                      subtitle: Text(
                        'Date: ${formatDate(alarm['date'])} | Time: ${alarm['time']}',
                      ),
                      trailing: const Icon(Icons.access_alarm),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
