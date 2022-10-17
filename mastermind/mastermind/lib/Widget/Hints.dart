import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'Circle.dart';

class Hints extends StatelessWidget {
  List<Color> hints;
  Hints(this.hints, {super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(0),
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        crossAxisCount: 2,
        children: List.generate(
          4,
          (i) => Container(
            padding: const EdgeInsets.all(0),
            child: Circle(50, 50, hints[i]),
          ),
        ));
  }
}
