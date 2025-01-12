import 'package:flutter/material.dart';
import 'package:myeongsub_kim_pomodoro/screens/pomodoro_timer.dart';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1E1E2C),
        colorScheme: const ColorScheme.dark(
          primary: Color.fromARGB(255, 59, 13, 80),
          secondary: Color(0xFF4B6584),
          surface: Colors.grey,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          primaryContainer: Color(0xFF1A1A2E),
          secondaryContainer: Color(0xFF34495E),
        ),
      ),
      home: const PomodoroTimer(),
    );
  }
}
