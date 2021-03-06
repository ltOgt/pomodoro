import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pomodoro/background/star/star_painter_widget.dart';

import 'package:ltogt_utils_flutter/ltogt_utils_flutter.dart';

void main() {
  runApp(
    MaterialApp(
      title: '', // TODO add title
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(child: PomodoroTimerWidget()),
      ),
    ),
  );
}

class PomodoroTimerWidget extends StatefulWidget {
  const PomodoroTimerWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<PomodoroTimerWidget> createState() => _PomodoroTimerWidgetState();
}

class _PomodoroTimerWidgetState extends State<PomodoroTimerWidget> {
  Duration? duration;

  int get minutes => duration!.inSeconds ~/ 60;
  int get seconds => duration!.inSeconds % 60;
  String get durationText => "$minutes:${(seconds < 10 ? "0" : "")}$seconds";

  Timer? _timer;
  late TextEditingController _txtCtrl;
  late AudioPlayer _audioPlayer;
  @override
  void initState() {
    super.initState();
    _txtCtrl = TextEditingController();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _txtCtrl.dispose();
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void startTimer() {
    _audioPlayer.stop();

    final int minutes = int.tryParse(_txtCtrl.text) ?? 60;
    duration ??= Duration(minutes: minutes);

    // call once without waiting
    _timerCallback();

    _timer = Timer.periodic(
      sixtyFPS,
      (Timer timer) => _timerCallback(),
    );
  }

  void _timerCallback() async {
    if (duration!.inSeconds == 0) {
      endTimer();
    } else {
      setState(() {
        duration = duration! - sixtyFPS;
      });
    }
  }

  void endTimer() async {
    if (_timer != null) {
      await _audioPlayer.setAsset("asset/bell.mp3");
      _audioPlayer.setLoopMode(LoopMode.one);
      _audioPlayer.play();
    }
    pauseTimer();
  }

  void pauseTimer() {
    _timer?.cancel();
    setState(() {
      _timer = null;
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _audioPlayer.stop();
    setState(() {
      _timer = null;
      duration = null;
    });
  }

  String _pad(int v, int max) => NumHelper.paddedString(v, max);
  String? get timeForClockText => timeForClock == null //
      ? null
      : (_pad(timeForClock!.hour, 24) + ":" + _pad(timeForClock!.minute, 59));
  DateTime? timeForClock;
  void _clockCallback() {
    setState(() {
      timeForClock = DateTime.now();
    });
  }

  void startClock() {
    _timer = Timer.periodic(
      sixtyFPS,
      (Timer timer) => _clockCallback(),
    );
  }

  void stopClock() {
    _timer?.cancel();
    setState(() {
      _timer = null;
      timeForClock = null;
    });
  }

  static const darkColor = Color(0xFF111111);
  static const sizedBox = SizedBox(height: 18);
  static const sixtyFPS = Duration(milliseconds: 16);
  static const fontStyle = TextStyle(
    color: Colors.white,
    fontSize: 60,
  );

  bool get isStopped => duration == null;
  bool get isPaused => !isStopped && _timer == null;
  bool get isTicking => !isStopped && _timer != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      // show dart color if timer is running TODO animate outwards
      constraints: const BoxConstraints.expand(
        height: double.infinity,
        width: double.infinity,
      ),
      color: (duration != null || timeForClock != null) ? darkColor : null,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          if (!isStopped || timeForClock != null) ...[
            StarPainterWidget(),
          ],
          isStopped && timeForClock == null
              // Show input if no duration has been set (or has been reset via STOP)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: startClock,
                      icon: const Icon(Icons.timelapse),
                    ),
                    ...times(3, sizedBox),
                    Container(
                      width: 100,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        color: darkColor,
                      ),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _txtCtrl,
                        maxLength: 3,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        decoration: const InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: "minutes",
                        ),
                      ),
                    ),
                    sizedBox,
                    IconButton(
                      onPressed: startTimer,
                      icon: const Icon(Icons.play_arrow),
                    ),
                  ],
                )
              // Show timer if duration is set
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      timeForClockText ?? durationText,
                      style: fontStyle,
                    ),
                    sizedBox,
                    isTicking
                        // Allow to pause if timer is running
                        ? IconButton(
                            onPressed: pauseTimer,
                            icon: const Icon(Icons.pause),
                          )
                        // Allow to continue or stop timer if it is paused
                        : timeForClock != null //
                            ? IconButton(
                                onPressed: stopClock,
                                icon: const Icon(Icons.arrow_back),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (duration!.inSeconds != 0)
                                    IconButton(
                                      onPressed: startTimer,
                                      icon: const Icon(Icons.play_arrow),
                                    ),
                                  IconButton(
                                    onPressed: stopTimer,
                                    icon: const Icon(Icons.stop),
                                  ),
                                ],
                              ),
                  ],
                ),
        ],
      ),
    );
  }
}
