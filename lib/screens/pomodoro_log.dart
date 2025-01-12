import 'dart:convert'; // <-- JSON 파싱을 위해 필요
import 'package:flutter/material.dart';
import 'package:myeongsub_kim_pomodoro/models/pomodoro_log_model.dart';
import 'package:myeongsub_kim_pomodoro/screens/daily_pomodoro_log.dart';
import 'package:myeongsub_kim_pomodoro/screens/daily_pomodoro_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class PomodoroLogPage extends StatefulWidget {
  const PomodoroLogPage({super.key});

  @override
  State<PomodoroLogPage> createState() => _PomodoroLogPageState();
}

class _PomodoroLogPageState extends State<PomodoroLogPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  int _totalRounds = 0;
  int _totalWorkTime = 0;

  // 전체 로그: String(JSON) 형태
  List<String> _logs = [];

  // 필터링된 로그(선택 날짜와 일치하는 것만)
  List<String> _filteredLogs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  /// SharedPreferences에서 로그를 불러오기
  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedLogs = prefs.getStringList('pomodoroLogs') ?? [];

    setState(() {
      _logs = loadedLogs;
    });

    // 초기 진입 시, 오늘 날짜로 필터링
    _filterLogsByDate(_selectedDay);
  }

  /// 선택된 날짜를 기반으로 _filteredLogs를 업데이트
  void _filterLogsByDate(DateTime date) {
    // 1) 선택 날짜를 yyyy-MM-dd 형태로 변환
    final selectedDateString = _formatDate(date);

    // 2) _logs 각 항목(문자열)을 JSON 파싱하여 "date" 필드가 selectedDateString과 같은지 검사
    final filtered = _logs.where((logString) {
      try {
        // 문자열 -> Map -> 모델
        final logMap = jsonDecode(logString) as Map<String, dynamic>;
        final logModel = PomodoroLogModel.fromJson(logMap);
        return logModel.date == selectedDateString;
      } catch (e) {
        return false;
      }
    }).toList();

    // 합계 계산
    int totalRounds = 0;
    int totalWorkTime = 0;
    for (final log in filtered) {
      final logMap = jsonDecode(log) as Map<String, dynamic>;
      final logModel = PomodoroLogModel.fromJson(logMap);
      totalRounds += logModel.round;
      totalWorkTime += logModel.round * logModel.workTime;
    }

    setState(() {
      _filteredLogs = filtered;
      _totalRounds = totalRounds;
      _totalWorkTime = totalWorkTime;
    });
  }

  /// DateTime -> yyyy-MM-dd
  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

// Total Rounds와 Work Time을 예쁘게 보여주는 UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Log'),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1E1E2C),
      ),
      body: Column(
        children: [
          // ---------------- TableCalendar ----------------
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              // 날짜를 시분초=0 형태로 정규화
              final normalized = DateTime(
                selectedDay.year,
                selectedDay.month,
                selectedDay.day,
              );

              setState(() {
                _selectedDay = normalized;
                _focusedDay = normalized;
              });

              // 선택 날짜 기준으로 로그 필터링
              _filterLogsByDate(normalized);
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red),
              defaultTextStyle: TextStyle(color: Colors.white),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            _formatDate(_selectedDay),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),
          if (_filteredLogs.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DailyPomodoroLog(filteredLogs: _filteredLogs),
                  ),
                );
              },
              child: DailySummary(
                totalRounds: _totalRounds,
                totalWorkTime: _totalWorkTime,
              ),
            ),
        ],
      ),
      backgroundColor: const Color(0xFF1E1E2C),
    );
  }
}
