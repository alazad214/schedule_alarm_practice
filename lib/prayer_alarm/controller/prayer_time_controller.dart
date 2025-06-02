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

  void updatePrayerTime() {
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

  Future<void> setAlarmState(
    String city,
    String date,
    String prayerName,
    bool isEnabled,
  ) async {
    await _dbHelper.insertOrUpdateAlarm(city, date, prayerName, isEnabled);
  }
}
