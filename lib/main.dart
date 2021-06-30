import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

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
      color: duration != null ? darkColor : null,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          if (!isStopped) ...[
            StarPainterPainter(duration: duration),
          ],
          isStopped
              // Show input if no duration has been set (or has been reset via STOP)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                      durationText,
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

class StarPainterPainter extends StatefulWidget {
  const StarPainterPainter({
    Key? key,
    required this.duration,
  }) : super(key: key);

  final Duration? duration;

  @override
  State<StarPainterPainter> createState() => _StarPainterPainterState();
}

class _StarPainterPainterState extends State<StarPainterPainter> {
  List<Star> stars = [];

  Size previousSize = const Size(0, 0);

  @override
  void didChangeDependencies() {
    final newSize = MediaQuery.of(context).size;
    if (newSize != previousSize) {
      previousSize = newSize;
      stars = [];
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: Container(
        // show dart color if timer is running TODO animate outwards
        constraints: const BoxConstraints.expand(
          height: double.infinity,
          width: double.infinity,
        ),
      ),
      painter: StartPainter(
        maxRadius: 1.5,
        stars: stars,
        numberOfStars: ((previousSize.width * previousSize.height) / 500).round(),
        movement: const Offset(0.01, 0.02),
      ),
    );
  }
}

class Star {
  Offset position;
  double width;
  double brightness;

  Offset movementAdjust;
  Star({
    required this.position,
    required this.width,
    required this.brightness,
    required this.movementAdjust,
  });
}

class StartPainter extends CustomPainter {
  final int numberOfStars;
  final double maxRadius;
  final List<Star> stars;
  final random = Random();
  final Offset movement;
  Paint starPaint = Paint();

  StartPainter({
    required this.numberOfStars,
    required this.maxRadius,
    required this.stars,
    required this.movement,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stars.isEmpty) {
      for (int i = 0; i < numberOfStars; i++) {
        stars.add(
          Star(
            position: Offset(
              random.nextDouble() * size.width,
              random.nextDouble() * size.height,
            ),
            width: random.nextDouble() * maxRadius,
            brightness: random.nextDouble(),
            movementAdjust: Offset(
              random.nextDouble() * 0.02,
              random.nextDouble() * 0.02,
            ),
          ),
        );
      }
    }
    for (final star in stars) {
      Offset newPosition = star.position + movement + star.movementAdjust;
      double x = newPosition.dx;
      double y = newPosition.dy;

      // wrap around at edges
      if (x > size.width) {
        x = 0;
      } else if (x < 0) {
        x = size.width;
      }
      if (y > size.height) {
        y = 0;
      } else if (y < 0) {
        y = size.height;
      }

      star.position = Offset(x, y);

      canvas.drawCircle(
        star.position,
        star.width,
        starPaint
          ..color = Color.fromARGB(
            (255 * star.brightness).round().clamp(0, 255),
            255,
            255,
            255,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(StartPainter oldDelegate) => true;
}
