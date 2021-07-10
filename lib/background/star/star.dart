import 'dart:ui';

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
