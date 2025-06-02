class PrayerTimeModel {
  final String city;
  final String date;
  final String day;
  final Map<String, String> times;

  PrayerTimeModel({
    required this.city,
    required this.date,
    required this.day,
    required this.times,
  });

  factory PrayerTimeModel.fromList(List<dynamic> row) {
    return PrayerTimeModel(
      city: row[0],
      date: row[1],
      day: row[2],
      times: {
        'Imsaak': row[3],
        'Dawn': row[4],
        'Sunrise': row[5],
        'Noon': row[6],
        'Asr': row[7],
        'Sunset': row[8],
        'Maghrib': row[9],
        'Midnight': row[10],
      },
    );
  }
}

class AlarmModel {
  final String city;
  final String date;
  final String prayerName;
  final bool isEnabled;

  AlarmModel({
    required this.city,
    required this.date,
    required this.prayerName,
    required this.isEnabled,
  });

  Map<String, dynamic> toMap() => {
    'city': city,
    'date': date,
    'prayerName': prayerName,
    'isEnabled': isEnabled ? 1 : 0,
  };

  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      city: map['city'],
      date: map['date'],
      prayerName: map['prayerName'],
      isEnabled: map['isEnabled'] == 1,
    );
  }
}
