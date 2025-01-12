import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myeongsub_kim_pomodoro/components/log_card.dart';
import 'package:myeongsub_kim_pomodoro/models/pomodoro_log_model.dart';

class DailyPomodoroLog extends StatelessWidget {
  const DailyPomodoroLog({
    super.key,
    required List<String> filteredLogs,
  }) : _filteredLogs = filteredLogs;

  final List<String> _filteredLogs;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: _filteredLogs.length,
        itemBuilder: (context, index) {
          final logString = _filteredLogs[index];
          try {
            // 문자열 -> Map -> 모델
            final logMap = jsonDecode(logString) as Map<String, dynamic>;
            final logModel = PomodoroLogModel.fromJson(logMap);

            return PomodoroLogCard(logModel: logModel);
          } catch (e) {
            // 파싱 실패: 그냥 원본 문자열 출력
            return ListTile(
              title: Text(
                'Invalid JSON: $logString',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
        },
      ),
    );
  }
}
