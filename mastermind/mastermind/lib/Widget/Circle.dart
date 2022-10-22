// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';

class Circle extends StatelessWidget {
  Color color;
  double x;
  double y;
  Circle(this.x, this.y, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
        padding: EdgeInsets.all(width * 0.02),
        child: CustomPaint(
          size: Size(this.x, this.y),
          painter: CirclePainter(color),
        ));
  }
}

class CirclePainter extends CustomPainter {
  Color colors;

  CirclePainter(this.colors);
  @override
  void paint(Canvas canvas, Size size) {
    final _paint = Paint()
      ..color = colors
      ..strokeWidth = 2
      // Use [PaintingStyle.fill] if you want the circle to be filled.
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.width, size.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
