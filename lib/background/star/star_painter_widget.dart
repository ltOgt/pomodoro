import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pomodoro/background/star/star.dart';
import 'package:pomodoro/background/star/star_painter.dart';

class StartPainterWidget extends StatefulWidget {
  const StartPainterWidget({
    Key? key,
    required this.duration,
  }) : super(key: key);

  final Duration? duration;

  @override
  State<StartPainterWidget> createState() => _StartPainterWidgetState();
}

class _StartPainterWidgetState extends State<StartPainterWidget> {
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
