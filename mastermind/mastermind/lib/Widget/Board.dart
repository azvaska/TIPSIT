import 'package:flutter/material.dart';
import 'package:mastermind/Controller.dart';
import 'package:mastermind/Widget/Exceptions.dart';
import 'package:mastermind/Widget/Settings.dart';
import 'package:mastermind/Widget/WinLost.dart';
import 'Colorpicker.dart';
import 'CombinationRow.dart';
import 'package:flutter/services.dart';

class Board extends StatefulWidget {
  final int nMaxRows;
  final bool duplicates;
  const Board({super.key, this.nMaxRows = 9, this.duplicates = true});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  late var controller;
  int nRows = 1;
  bool done = false;
  bool win = false;
  int nMaxRows = 9;
  bool duplicates = true;
  late List<List<Color>> combinations;
  List<Widget> BoardRowsWidgets = [];
  Color selectedColor = Colors.black;
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
    setState(() {
      done = false;
      win = false;
      combinations = [];
      combinations.addAll(List.generate(widget.nMaxRows,
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
      if (i + 1 == widget.nMaxRows) {
        //Lost
        setState(() {
          done = true;
        });
        controller.genCombination();
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
      controller.genCombination();
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
    controller = Controller(widget.duplicates);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
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
          Duration.zero, () => WinLost(restart, win).showAlertDialog(context));
    }
    var height = MediaQuery.of(context).viewPadding.top;
    return Stack(children: [
      Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Column(
          children: [
            SizedBox(
                height: 120.0,
                child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                    ),
                    margin: const EdgeInsets.all(0.0),
                    padding: EdgeInsets.fromLTRB(0.0, height, 0.0, 0.0),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Settings(),
                ));
          },
          backgroundColor: Colors.black,
          child: const Icon(Icons.settings),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute<SettingsData>(
                builder: (context) => Settings(duplicates, nMaxRows),
              ))
              .then((value) => {
                    if (value != null)
                      {
                        setState(() {
                          duplicates = value.allowDuplicates;
                          nMaxRows = value.nRows;
                          restart();
                        })
                      }
                  });
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.settings),
      ),
    );
  }
}
