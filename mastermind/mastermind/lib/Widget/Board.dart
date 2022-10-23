import 'package:flutter/material.dart';
import 'package:mastermind/Controller.dart';
import 'package:mastermind/Widget/Exceptions.dart';
import 'package:mastermind/Widget/Settings.dart';
import 'package:mastermind/Widget/WinLost.dart';
import 'Colorpicker.dart';
import 'CombinationRow.dart';
import 'package:flutter/services.dart';

import 'Timer.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  late Controller controller;
  int nRows = 1;
  bool done = false;
  bool win = false;
  int nMaxRows = 9;
  bool duplicates = true;
  late List<List<Color>> combinations;
  List<Widget> BoardRowsWidgets = [];
  Color selectedColor = Colors.blue;
  void color_picked(Color C) {
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
    controller.genCombination();

    setState(() {
      done = false;
      win = false;
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

    controller = Controller(duplicates);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    restart();
  }

  @override
  Widget build(BuildContext context) {
    if (done) {
      Future.delayed(
          Duration.zero,
          () => WinLost(restart, win, controller.currenCombination)
              .showAlertDialog(context));
    }
    double height = MediaQuery.of(context).viewPadding.top;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Column(
          children: [
            SizedBox(
                height: 120.0,
                width: width,
                child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                    ),
                    margin: const EdgeInsets.all(0.0),
                    padding: EdgeInsets.fromLTRB(0.0, height, 0.0, 0.0),
                    child: ColorPicker(color_picked))),
            // ...List<Widget>.of(BoardRowsWidgets),
            Expanded(
                child: SingleChildScrollView(
                    child: Column(
                        children: List<Widget>.of(BoardRowsWidgets)
                            .reversed
                            .toList()))),
          ],
        ),
        floatingActionButton: Stack(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        restart();
                      });
                    },
                    backgroundColor: Colors.black,
                    child: const Icon(Icons.restart_alt),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                      textScaleFactor: 1.5,
                      "Tries left ${(nMaxRows - BoardRowsWidgets.length) + 1}")),
            ),
            TimerPage(),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute<SettingsData>(
                        builder: (context) => Settings(duplicates, nMaxRows),
                      ))
                      .then((value) => {
                            if (value != null)
                              {
                                if (duplicates != value.allowDuplicates ||
                                    nMaxRows != value.nRows)
                                  {
                                    setState(() {
                                      duplicates = value.allowDuplicates;
                                      controller = Controller(duplicates);
                                      nMaxRows = value.nRows;
                                      restart();
                                    })
                                  }
                              }
                          });
                },
                backgroundColor: Colors.black,
                child: const Icon(Icons.settings),
              ),
            ),
          ],
        ));
  }
}
