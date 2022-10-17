import 'package:flutter/material.dart';
import 'package:mastermind/Controller.dart';
import 'package:flutter/foundation.dart';
import 'package:mastermind/Widget/Exceptions.dart';
import 'package:mastermind/Widget/WinLost.dart';
import 'Colorpicker.dart';
import 'CombinationRow.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  var controller = Controller();
  int nRows = 1;
  bool done = false;
  bool win = false;
  static const int nMaxRows = 5;
  late List<List<Color>> combinations;
  List<Widget> BoardRowsWidgets = [];
  Color selectedColor = Colors.black;
  void color_picked(Color C) {
    print(C);
    setState(() {
      selectedColor = C;
    });
  }

  void circle_selected(int i, int y) {
    setState(() {
      combinations[i][y] = selectedColor;
      BoardRowsWidgets[i] = CombinationRow(
          combinations[i], i, circle_selected, checkCombination,
          key: UniqueKey());
    });
  }

  void restart() {
    setState(() {
      combinations = [];
      combinations.addAll(List.generate(nMaxRows,
          (index) => [Colors.grey, Colors.grey, Colors.grey, Colors.grey]));
      BoardRowsWidgets = [];
      BoardRowsWidgets.add(CombinationRow(
          combinations[0], 0, circle_selected, checkCombination,
          key: UniqueKey()));
    });
  }

  List<Color> checkCombination(int i) {
    try {
      var colors = controller.checkColors(combinations[i]);
      if (i + 1 == nMaxRows) {
        //Lost
        setState(() {
          done = true;
        });
        return [];
      }
      setState(() {
        BoardRowsWidgets.add(CombinationRow(
            combinations[i + 1], i + 1, circle_selected, checkCombination,
            key: UniqueKey()));
      });
      return colors;
    } on WinException {
      //WIN
      setState(() {
        win = true;
        done = true;
      });
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    combinations = [];
    combinations.addAll(List.generate(nMaxRows,
        (index) => [Colors.grey, Colors.grey, Colors.grey, Colors.grey]));
    BoardRowsWidgets.add(CombinationRow(
        combinations[0], 0, circle_selected, checkCombination,
        key: UniqueKey()));
  }

  @override
  Widget build(BuildContext context) {
    if (done) {
      Future.delayed(
          Duration.zero, () => WinLost(restart, win).showAlertDialog(context));
      done = false;
      win = false;
    }
    return Drawer(
      backgroundColor: Colors.blueGrey,
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Column(
        children: [
          SizedBox(
              height: 150.0,
              child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                  ),
                  margin: const EdgeInsets.all(0.0),
                  padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                  child: ColorPicker(color_picked))),
          // ...List<Widget>.of(BoardRowsWidgets),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.all(0.0),
                  shrinkWrap: true,
                  children:
                      List<Widget>.of(BoardRowsWidgets).reversed.toList())),
        ],
      ),
    );
  }
}
