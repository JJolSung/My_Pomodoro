import 'package:flutter/material.dart';
import 'package:myeongsub_kim_pomodoro/models/pomodoro_log_model.dart';

class PomodoroLogCard extends StatelessWidget {
  const PomodoroLogCard({
    super.key,
    required this.logModel,
  });

  final PomodoroLogModel logModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Round: ${logModel.round}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'WorkTime: ${logModel.workTime} mins',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'BreakTime: ${logModel.breakTime} mins',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
