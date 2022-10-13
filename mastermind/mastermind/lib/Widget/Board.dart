import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mastermind/Controller.dart';

import 'Circle.dart';
import 'Colorpicker.dart';
import 'EmptyRow.dart';
import 'Rows.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  var controller = Controller();
  var board_s = [];
  Color selectedColor = Colors.black;
  void color_picked(Color C) {
    setState(() {
      selectedColor = C;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.amber,
              ),
              child: ColorPicker(color_picked)),
          const Rows(),
        ],
      ),
    );
  }
}
