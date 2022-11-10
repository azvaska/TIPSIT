import 'package:flutter/material.dart';

// KeyPad widget
// This widget is reusable and its buttons are customizable (color, size)
class NumPad extends StatelessWidget {
  final double buttonSize;
  final Color buttonColor;
  final Color iconColor;
  final TextEditingController controller;
  final Function delete;
  final Function onSubmit;

  const NumPad({
    Key? key,
    this.buttonSize = 100,
    this.buttonColor = Colors.indigo,
    this.iconColor = Colors.amber,
    required this.delete,
    required this.onSubmit,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    var safeHeight = height - padding.top - padding.bottom;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 30, right: 30),
        child: Column(
          children: [
            SizedBox(height: safeHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // implement the number keys (from 0 to 9) with the NumberButton widget
              // the NumberButton widget is defined in the bottom of this file
              children: [
                NumberButton(
                  number: 1,
                  size: buttonSize,
                  color: buttonColor,
                  controller: controller,
                ),
                NumberButton(
                  number: 2,
                  size: buttonSize,
                  color: buttonColor,
                  controller: controller,
                ),
                NumberButton(
                  number: 3,
                  size: buttonSize,
                  color: buttonColor,
                  controller: controller,
                ),
              ],
            ),
            SizedBox(height: safeHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NumberButton(
                  number: 4,
                  size: buttonSize,
                  color: buttonColor,
                  controller: controller,
                ),
                NumberButton(
                  number: 5,
                  size: buttonSize,
                  color: buttonColor,
                  controller: controller,
                ),
                NumberButton(
                  number: 6,
                  size: buttonSize,
                  color: buttonColor,
                  controller: controller,
                ),
              ],
            ),
            SizedBox(height: safeHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NumberButton(
                  number: 7,
                  size: buttonSize,
                  color: buttonColor,
                  controller: controller,
                ),
                NumberButton(
                  number: 8,
                  size: buttonSize,
                  color: buttonColor,
                  controller: controller,
                ),
                NumberButton(
                  number: 9,
                  size: buttonSize,
                  color: buttonColor,
                  controller: controller,
                ),
              ],
            ),
            SizedBox(height: safeHeight * 0.01),
            Padding(
              padding: const EdgeInsets.only(left: 9, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NumberButton(
                    number: 0,
                    size: buttonSize,
                    color: buttonColor,
                    controller: controller,
                    customNumber: "00",
                  ),
                  // this button is used to delete the last number

                  NumberButton(
                    number: 0,
                    size: buttonSize,
                    color: buttonColor,
                    controller: controller,
                  ),
                  IconButton(
                    onPressed: () => delete(),
                    icon: Icon(
                      Icons.backspace,
                      color: iconColor,
                    ),
                    iconSize: buttonSize,
                  ),
                  // this button is used to submit the entered value
                ],
              ),
            ),
            IconButton(
              onPressed: () => onSubmit(),
              icon: Icon(
                Icons.done_rounded,
                color: iconColor,
              ),
              iconSize: buttonSize,
            ),
          ],
        ),
      ),
    );
  }
}

// define NumberButton widget
// its shape is round
class NumberButton extends StatelessWidget {
  final int number;
  final double size;
  final Color color;
  final TextEditingController controller;
  final String customNumber;
  const NumberButton(
      {Key? key,
      required this.number,
      required this.size,
      required this.color,
      required this.controller,
      this.customNumber = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size / 2),
          ),
        ),
        onPressed: () {
          if (customNumber.isNotEmpty) {
            controller.text = customNumber;
          } else {
            controller.text = number.toString();
          }
        },
        child: Center(
          child: Text(
            customNumber.isEmpty ? number.toString() : customNumber,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30),
          ),
        ),
      ),
    );
  }
}
