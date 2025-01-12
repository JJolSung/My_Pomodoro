import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myeongsub_kim_pomodoro/models/pomodoro_log_model.dart';
import 'package:myeongsub_kim_pomodoro/screens/pomodoro_log.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

enum PomodoroMode { work, breakTime }

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  PomodoroTimerState createState() => PomodoroTimerState();
}

class PomodoroTimerState extends State<PomodoroTimer> {
  late Timer _timer;
  late SharedPreferences prefs;

  int _remainingTime = 1500;
  bool _isRunning = false;

  double _workTime = 25.0;
  double _break = 5.0;
  int _totalPomodoroRound = 1;
  int _completedPomodoroRound = 0;

  PomodoroMode _currentMode = PomodoroMode.work;

  final TextEditingController _roundController = TextEditingController();

  void _onPomodoroRoundsCompleted() async {
    // SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white),
        ),
        content: Text(
          'Pomodoro Rounds Completed!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // 현재 날짜
    final now = DateTime.now();
    final dateString =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final newLog = PomodoroLogModel(
      round: _totalPomodoroRound,
      workTime: _workTime.toInt(),
      breakTime: _break.toInt(),
      date: dateString,
    );
    final logString = jsonEncode(newLog.toJson());
    final prefs = await SharedPreferences.getInstance();
    final logList = prefs.getStringList('pomodoroLogs') ?? [];

    logList.add(logString);
    // final roundInfo = {
    //   'round': _totalPomodoroRound,
    //   'workTime': _workTime.toInt(),
    //   'breakTime': _break.toInt(),
    //   'date': dateString,
    // };
    // final roundInfoJson = jsonEncode(roundInfo);

    // SharedPreferences 가져오기

    // 기존에 저장된 로그 리스트 불러오기(없으면 빈 리스트)
    // List<String> logList = prefs.getStringList('pomodoroLogs') ?? [];

    // 다시 저장
    await prefs.setStringList('pomodoroLogs', logList);

    // 타이머 초기화
    _resetTimer();
  }

  void _startTimer() {
    if (_isRunning) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
          _isRunning = false;

          // 모든 라운드가 완료된 경우 종료
          if (_currentMode == PomodoroMode.breakTime) {
            _completedPomodoroRound++;

            if (_completedPomodoroRound >= _totalPomodoroRound) {
              _onPomodoroRoundsCompleted();
              return;
            }
          }

          // 자동 모드 전환
          if (_currentMode == PomodoroMode.work) {
            _currentMode = PomodoroMode.breakTime;
            _remainingTime = (_break * 60).toInt();
            _startTimer(); // 휴식 시작
          } else if (_currentMode == PomodoroMode.breakTime) {
            _currentMode = PomodoroMode.work;
            _remainingTime = (_workTime * 60).toInt();
            _startTimer(); // 작업 시간 재시작
          }
        }
      });
    });

    setState(() {
      _isRunning = true;
    });
  }

  void _pauseTimer() {
    if (_timer.isActive) {
      _timer.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resetTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _currentMode = PomodoroMode.work;
      _remainingTime = (_workTime * 60).toInt();
      _isRunning = false;
      _completedPomodoroRound = 0;
    });
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 모드(Work, Break)에 따라 배경색 변경
    Color backgroundColor;
    if (_currentMode == PomodoroMode.work) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
    } else {
      backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
    }

    return Scaffold(
      // Drawer: 설정 관련 UI
      drawer: Drawer(
        child: Container(
          color: backgroundColor,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Work: ${_workTime.toInt()} min',
                    ),
                  ),
                  Slider(
                    value: _workTime,
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: _workTime.toInt().toString(),
                    onChanged: _isRunning
                        ? null
                        : (value) {
                            setState(() {
                              _workTime = value;
                              if (_currentMode == PomodoroMode.work) {
                                _remainingTime = (_workTime * 60).toInt();
                              }
                            });
                          },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Short Break: ${_break.toInt()} min',
                    ),
                  ),
                  Slider(
                    value: _break,
                    min: 1,
                    max: 15,
                    divisions: 14,
                    label: _break.toInt().toString(),
                    onChanged: _isRunning
                        ? null
                        : (value) {
                            setState(() {
                              _break = value;
                            });
                          },
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rounds: $_totalPomodoroRound',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _roundController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter total rounds',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    enabled: !_isRunning,
                    onSubmitted: (value) {
                      setState(() {
                        _totalPomodoroRound = int.tryParse(value) ?? 1;
                        _completedPomodoroRound = 0; // 라운드 초기화
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PomodoroLogPage(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        const Icon(
                          Icons.calendar_month_sharp,
                          color: Colors.white,
                        ),
                        const Text(
                          'Pomodoro Log',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          color: backgroundColor,
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Align(
              child: const Text(
                'Pomodoro Timer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white, size: 30),
          ),
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 원형 타이머
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 1 -
                        (_remainingTime /
                            (_currentMode == PomodoroMode.work
                                ? (_workTime * 60)
                                : (_break * 60))),
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _currentMode == PomodoroMode.work
                          ? const Color.fromARGB(255, 22, 136, 64)
                          : const Color(0xFF16A085),
                    ),
                    backgroundColor: _currentMode == PomodoroMode.work
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                  Center(
                    child: Text(
                      _formatTime(_remainingTime),
                      style: const TextStyle(
                        fontSize: 48,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 진행 상황
            Text(
              'Round : $_totalPomodoroRound / $_completedPomodoroRound',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            // 타이머 제어 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  iconSize: 48,
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                ),
                const SizedBox(width: 30),
                IconButton(
                  icon: const Icon(Icons.stop),
                  iconSize: 48,
                  onPressed: _resetTimer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
