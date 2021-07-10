import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pomodoro/background/star/star.dart';

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
