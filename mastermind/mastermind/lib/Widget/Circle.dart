import 'package:flutter/material.dart';


class Circle extends StatelessWidget {
  int n_th;
  int 
  const Circle(this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: InkWell(
                              onTap: () {},
                              child: CustomPaint(
                                size: const Size(70, 70),
                                painter: CirclePainter(
                                    controller.currenCombination[i]),
                              )));
  }
}

class CirclePainter extends CustomPainter {
  Color colors;

  CirclePainter(Color this.colors);
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

sta