import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:alarm_app/prayer_alarm/widgets/seven_days_widget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../controller/prayer_time_controller.dart';
import '../widgets/city_dropdown.dart';
import '../widgets/prayer_time_card.dart';

class PrayerAlarmScreen extends StatefulWidget {
  const PrayerAlarmScreen({super.key});

  @override
  State<PrayerAlarmScreen> createState() => _PrayerAlarmScreenState();
}

class _PrayerAlarmScreenState extends State<PrayerAlarmScreen> {
  final controller = Get.put(PrayerTimeController());
  int generateAlarmId(String city, String date, String prayerName) {
    return (city + date + prayerName).hashCode;
  }

  DateTime parsePrayerTime(String time, DateTime date) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.availableDates.isNotEmpty)
                  SevenDaySelector(
                    dates:
                        controller.availableDates
                            .map((d) => "${d.day}")
                            .toList(),
                    days:
                        controller.availableDates
                            .map(
                              (d) =>
                                  [
                                    'Sun',
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                  ][d.weekday % 7],
                            )
                            .toList(),
                    selectedIndex: controller.selectedDays.value,
                    onDateSelected: controller.onDateSelected,
                    selectedContainerColor: Colors.cyan,
                    unselectedContainerColor: const Color(0x19187488),
                    selectedTextColor: Colors.black,
                    unselectedTextColor: Colors.black,
                  ),
                const SizedBox(height: 20),
                if (controller.availableCities.isNotEmpty)
                  CityDropdown(
                    title: "Prayer Alarm",
                    cities: controller.availableCities,
                    selectedCity: controller.selectedCity.value,
                    selectedTextColor: Colors.cyan,
                    defaultTextColor: Colors.cyan,
                    onChanged: controller.onCityChanged,
                  ),
                const SizedBox(height: 10),
                if (controller.currentPrayerTime.value != null)
                  Column(
                    children:
                        controller.currentPrayerTime.value!.times.entries.map((
                          entry,
                        ) {
                          final prayerName = entry.key;
                          final prayerTime = entry.value;
                          final selectedDate =
                              controller.availableDates[controller
                                  .selectedDays
                                  .value];
                          final dateStr =
                              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

                          return FutureBuilder<bool>(
                            future: controller.isAlarmEnabled(
                              controller.selectedCity.value,
                              dateStr,
                              prayerName,
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              final isEnabled = snapshot.data ?? false;

                              return buildPrayerTimeWidget(
                                name: prayerName,
                                time: prayerTime,
                                icon: Icons.access_time,
                                switchWidget: Switch(
                                  value: isEnabled,
                                  onChanged: (val) async {
                                    await controller.setAlarmState(
                                      controller.selectedCity.value,
                                      dateStr,
                                      prayerName,
                                      val,
                                    );
                                    if (val) {
                                      final alarmTime = parsePrayerTime(
                                        prayerTime,
                                        selectedDate,
                                      );
                                      await Alarm.set(
                                        alarmSettings: AlarmSettings(
                                          id: generateAlarmId(
                                            controller.selectedCity.value,
                                            dateStr,
                                            prayerName,
                                          ),
                                          dateTime: alarmTime,
                                          assetAudioPath:
                                              'assets/audio/alarm.mp3',
                                          loopAudio: false,
                                          vibrate: true,
                                          warningNotificationOnKill:
                                              Platform.isIOS,
                                          androidFullScreenIntent: true,
                                          volumeSettings: VolumeSettings.fade(
                                            volume: 0.8,
                                            fadeDuration: const Duration(
                                              seconds: 5,
                                            ),
                                            volumeEnforced: true,
                                          ),
                                          notificationSettings:
                                              NotificationSettings(
                                                title: 'Alarm for $prayerName',
                                                body:
                                                    'It\'s time for $prayerName in ${controller.selectedCity.value}',
                                                stopButton: 'Stop',
                                                icon: 'notification_icon',
                                              ),
                                        ),
                                      );
                                      setState(() {});
                                    } else {
                                      await Alarm.stop(
                                        generateAlarmId(
                                          controller.selectedCity.value,
                                          dateStr,
                                          prayerName,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        }).toList(),
                  )
                else
                  const Text("No data available"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
