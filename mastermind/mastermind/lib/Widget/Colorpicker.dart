import 'package:flutter/material.dart';
import 'package:mastermind/Widget/Circle.dart';
import '../Controller.dart';

class ColorPicker extends StatefulWidget {
  final ValueSetter<Color> colorPicker;
  const ColorPicker(this.colorPicker, {super.key});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  Color selected = Controller.colors[0];
  @override
  Widget build(BuildContext context) {
    return Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 0.0,
        children: List.generate(
          Controller.colors.length,
          (i) => InkWell(
              onTap: () {
                setState(() {
                  selected = Controller.colors[i];
                  widget.colorPicker(Controller.colors[i]);
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 0),
                child: Container(
                  decoration: selected == Controller.colors[i]
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(width: 3, color: Colors.white))
                      : null,
                  child: Circle(45, 45, Controller.colors[i]),
                ),
              )),
        ).toList());
  }
}
