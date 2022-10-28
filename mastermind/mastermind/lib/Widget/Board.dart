// ignore: file_names
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mastermind/Widget/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'package:mastermind/Controller.dart';
import 'package:mastermind/Widget/exceptions.dart';
import 'package:mastermind/Widget/Settings.dart';
import 'package:mastermind/Widget/WinLost.dart';

import 'Colorpicker.dart';
import 'CombinationRow.dart';

import 'Timer.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> with WidgetsBindingObserver {
  late Controller controller;
  int nRows = 1;
  late SharedPreferences prefs;
  late Dependencies timerController;
  int nMaxRows = 9;
  bool duplicates = true;
  bool timerisRunning = false;
  late List<List<Color>> combinations;
  List<Widget> boardRowsWidgets = [];
  Color selectedColor = Colors.blue;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    timerController = Dependencies();
    controller = Controller(duplicates);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    initPrefs();
    restart();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void restart() {
    controller.genCombination();
    timerController.stopwatch.reset();

    setState(() {
      combinations = [];
      combinations.addAll(List.generate(nMaxRows,
          (index) => [Colors.grey, Colors.grey, Colors.grey, Colors.grey]));
      boardRowsWidgets = [];
      boardRowsWidgets.add(CombinationRow(
          combinations[0], 0, circleSelected, checkCombination,
          key: UniqueKey()));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (AppLifecycleState.paused == state) {
      timerController.stopwatch.stop();
    } else if (AppLifecycleState.resumed == state) {
      if (timerisRunning) timerController.stopwatch.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void colorPicked(Color C) {
    setState(() {
      selectedColor = C;
    });
  }

  void circleSelected(int i, int y) {
    timerController.stopwatch.start();
    setState(() {
      timerisRunning = true;
      combinations[i][y] = selectedColor;
      boardRowsWidgets[i] = CombinationRow(
          combinations[i], i, circleSelected, checkCombination,
          key: UniqueKey());
    });
  }

  List<Color> checkCombination(int i) {
    try {
      List<Color> colors = controller.checkColors(combinations[i]);
      if (i + 1 == nMaxRows) {
        //Lost
        WinLost(
                restart,
                false,
                controller.currenCombination,
                timerController.stopwatch.elapsedMilliseconds,
                prefs.getInt(Utils.bestTimeKey))
            .showAlertDialog(context);
        setState(() {
          timerController.stopwatch.stop();
          timerisRunning = false;
        });
        return [];
      }
      setState(() {
        boardRowsWidgets.add(CombinationRow(
            combinations[i + 1], i + 1, circleSelected, checkCombination,
            key: UniqueKey()));
      });
      return colors;
    } on WinException {
      //WIN
      int bestTime = min(prefs.getInt(Utils.bestTimeKey) ?? Utils.maxInt,
          timerController.stopwatch.elapsedMilliseconds);
      Future.delayed(Duration.zero, () async {
        await prefs.setInt(Utils.bestTimeKey, bestTime);
      });
      WinLost(restart, true, controller.currenCombination,
              timerController.stopwatch.elapsedMilliseconds, bestTime)
          .showAlertDialog(context);
      setState(() {
        timerController.stopwatch.stop();
        timerisRunning = false;
      });
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child: ColorPicker(colorPicked))),
            Expanded(
                child: SingleChildScrollView(
                    child: Column(
                        children: List<Widget>.of(boardRowsWidgets)
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
                    heroTag: "btn1",
                    onPressed: () {
                      timerController.stopwatch.stop();

                      setState(() {
                        timerisRunning = false;

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
                      style: const TextStyle(
                          color: Color.fromARGB(255, 164, 177, 183)),
                      textScaleFactor: 1.7,
                      "Tries left ${(nMaxRows - boardRowsWidgets.length) + 1}")),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: TimerPage(timerController)),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: "btn2",
                onPressed: () {
                  timerController.stopwatch.stop();
                  Navigator.of(context)
                      .push(MaterialPageRoute<SettingsData>(
                    builder: (context) => Settings(SettingsData(
                        allowDuplicates: duplicates, nRows: nMaxRows)),
                  ))
                      .then((value) {
                    if (value != null) {
                      if (duplicates != value.allowDuplicates ||
                          nMaxRows != value.nRows) {
                        setState(() {
                          duplicates = value.allowDuplicates;
                          controller = Controller(duplicates);
                          nMaxRows = value.nRows;
                          restart();
                        });
                      } else {
                        if (timerisRunning) timerController.stopwatch.start();
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
