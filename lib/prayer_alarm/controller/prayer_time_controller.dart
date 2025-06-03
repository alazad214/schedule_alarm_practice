import 'package:alarm_app/prayer_alarm/model/prayer_time_model.dart';
import 'package:alarm_app/prayer_alarm/services/alarm_db_helper.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PrayerTimeController extends GetxController {
  var selectedDays = 0.obs;
  var selectedCity = 'City 1'.obs;
  var prayerTimes = <PrayerTimeModel>[].obs;
  var currentPrayerTime = Rxn<PrayerTimeModel>();
  var availableDates = <DateTime>[].obs;
  var availableCities = <String>[].obs;
  var alarmSwitchStates = <String, bool>{}.obs;

  final PrayerDBHelper _dbHelper = PrayerDBHelper.instance;

  @override
  void onInit() {
    super.onInit();
    loadCSV();
  }

  Future<void> loadCSV() async {
    final rawData = await rootBundle.loadString('assets/csv/prayer_data.csv');
    List<List<dynamic>> rows = const CsvToListConverter().convert(
      rawData,
      eol: '\n',
    );
    final dataRows = rows.skip(1);

    final loadedTimes =
        dataRows.map((row) => PrayerTimeModel.fromList(row)).toList();
    final cities = loadedTimes.map((e) => e.city).toSet().toList();

    prayerTimes.assignAll(loadedTimes);
    availableCities.assignAll(cities);
    selectedCity.value = cities.first;

    updateAvailableDates();
    updatePrayerTime();
  }

  Future<void> loadAllAlarmStates() async {
    final newStates = <String, bool>{};

    if (currentPrayerTime.value == null) return;

    final selectedDate = availableDates[selectedDays.value];
    final dateStr =
        "${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    for (var prayerName in currentPrayerTime.value!.times.keys) {
      bool isEnabled = await _dbHelper.getAlarmState(
        selectedCity.value,
        dateStr,
        prayerName,
      );
     final key = "${selectedCity.value}|$dateStr|$prayerName";

      newStates[key] = isEnabled;
    }

    alarmSwitchStates.assignAll(newStates);
    alarmSwitchStates.refresh(); // 🔁 force UI to update
  }

  void updateAvailableDates() {
    final today = DateTime.now();
    final filteredDates =
        prayerTimes
            .where(
              (pt) =>
                  pt.city == selectedCity.value &&
                  DateTime.parse(
                    pt.date,
                  ).isAfter(today.subtract(const Duration(days: 1))),
            )
            .map((pt) => DateTime.parse(pt.date))
            .toList();

    filteredDates.sort();
    availableDates.assignAll(filteredDates.take(7).toList());

    if (selectedDays.value >= availableDates.length) {
      selectedDays.value = 0;
    }
  }

  void updatePrayerTime() async {
    if (availableDates.isEmpty || selectedDays.value >= availableDates.length) {
      currentPrayerTime.value = null;
      return;
    }

    final selectedDate = availableDates[selectedDays.value];
    final todayStr =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    currentPrayerTime.value = prayerTimes.firstWhere(
      (pt) => pt.city == selectedCity.value && pt.date == todayStr,
      orElse:
          () => PrayerTimeModel(
            city: selectedCity.value,
            date: todayStr,
            day: '',
            times: {},
          ),
    );
    await loadAllAlarmStates();
  }

  void onDateSelected(int index) {
    selectedDays.value = index;
    updatePrayerTime();
  }

  void onCityChanged(String? value) {
    selectedCity.value = value!;
    selectedDays.value = 0;
    updateAvailableDates();
    updatePrayerTime();
  }

  Future<bool> isAlarmEnabled(
    String city,
    String date,
    String prayerName,
  ) async {
    return await _dbHelper.getAlarmState(city, date, prayerName);
  }

// PrayerTimeController.dart

// Loads one alarm state from DB and updates the map (called when key not present)
Future<void> loadAlarmState(String city, String date, String prayerName) async {
  final isEnabled = await _dbHelper.getAlarmState(city, date, prayerName);
  final key = "$city|$date|$prayerName";

  alarmSwitchStates[key] = isEnabled;
  alarmSwitchStates.refresh(); // Important to notify UI listeners
}

// Saves the alarm state into DB and updates the in-memory map + UI
Future<void> setAlarmState(
  String city,
  String date,
  String prayerName,
  bool isEnabled,
) async {
  await _dbHelper.insertOrUpdateAlarm(city, date, prayerName, isEnabled);
  final key = "$city|$date|$prayerName";

  alarmSwitchStates[key] = isEnabled;
  alarmSwitchStates.refresh(); // Force UI update immediately
}


}
