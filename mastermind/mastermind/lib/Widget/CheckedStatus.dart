import 'package:flutter/material.dart';
import 'package:mastermind/Widget/Hints.dart';

class CheckedStatus extends StatelessWidget {
  final bool checked;
  final List<Color> hints;
  const CheckedStatus(this.checked, this.hints, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: checked && hints.isNotEmpty
          ? Hints(hints)
          : Container(
              width: 55.0,
              height: 55.0,
              margin: const EdgeInsets.fromLTRB(15, 0, 10, 0),
              padding: const EdgeInsets.all(0.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              child: const Icon(
                Icons.done,
                color: Colors.white,
              )),
    );
  }
}
