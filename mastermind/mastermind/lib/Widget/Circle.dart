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
      child: Container(
        width: x,
        height: y,
        decoration: ShapeDecoration(
          shape: const CircleBorder(),
          color: color,
        ),
      ),
    );
  }
}
