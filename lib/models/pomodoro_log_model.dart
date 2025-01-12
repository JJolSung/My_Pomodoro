class PomodoroLogModel {
  final int round;
  final int workTime;
  final int breakTime;
  final String date;

  PomodoroLogModel({
    required this.round,
    required this.workTime,
    required this.breakTime,
    required this.date,
  });

  factory PomodoroLogModel.fromJson(Map<String, dynamic> json) {
    return PomodoroLogModel(
      round: json['round'] as int,
      workTime: json['workTime'] as int,
      breakTime: json['breakTime'] as int,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'round': round,
      'workTime': workTime,
      'breakTime': breakTime,
      'date': date,
    };
  }
}
