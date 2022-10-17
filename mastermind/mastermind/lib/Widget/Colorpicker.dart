import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mastermind/Widget/Circle.dart';
import '../Controller.dart';

class ColorPicker extends StatelessWidget {
  final ValueSetter<Color> color_picker;

  const ColorPicker(this.color_picker, {super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 3.0,
        children: List.generate(
            Controller.colors.length,
            (i) => InkWell(
                onTap: () => {color_picker(Controller.colors[i])},
                child: Circle(45, 45, Controller.colors[i]))).toList());
  }
}
