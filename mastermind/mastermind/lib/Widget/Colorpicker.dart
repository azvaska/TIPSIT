import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mastermind/Widget/Circle.dart';
import '../Controller.dart';

class ColorPicker extends StatefulWidget {
  final ValueSetter<Color> color_picker;
  const ColorPicker(this.color_picker, {super.key});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  Color selected = Controller.colors[0];
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 0.0,
        children: List.generate(
            Controller.colors.length,
            (i) => InkWell(
                  onTap: () => {widget.color_picker(Controller.colors[i])},
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: Circle(45, 45, Controller.colors[i]),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                )).toList());
  }
}
