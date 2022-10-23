import 'package:flutter/material.dart';

import 'Widget/Exceptions.dart';
import 'dart:math';

class Controller {
  static const int nCombination = 4;
  bool debug = false;
  bool duplicates = false;
  List<Color> currenCombination = [];

  Controller(this.duplicates);
  static const List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.white,
    Colors.green,
    Colors.black
  ];

  genCombination() {
    if (!duplicates) {
      List<Color> comb = List.from(colors);
      comb.shuffle();
      comb = comb.sublist(0, 4);
      currenCombination = comb;
      return;
    }
    Random rng = Random();
    currenCombination = List.generate(4, (index) => colors[rng.nextInt(6)]);
    //currenCombination = [Colors.black, Colors.green, Colors.black, Colors.blue];
  }

  checkColors(List<Color> guess) {
    var hints = <dynamic, dynamic>{};
    List<Color> hintsC = [];
    //doppi bianchi
    List<Color> localCombination = List.from(currenCombination);
    List<Color> localGuess = List.from(guess);

    int nRight = 0;
    // Correct color and position
    for (var i = 0; i < currenCombination.length; i++) {
      if (guess[i] == currenCombination[i]) {
        nRight++;
        if (hints[guess[i]] == null) {
          hints[guess[i]] = Colors.green;
        } else {
          hintsC.add(Colors.green);
        }
        localCombination.remove(guess[i]);
        localGuess.remove(guess[i]);
      }
    }
    if (nRight == nCombination) {
      throw WinException('WIN');
    }
    for (var i = 0; i < localGuess.length; i++) {
      // Correct color wrong position
      if (localCombination.contains(localGuess[i])) {
        if (hints[localGuess[i]] == null) {
          hints[localGuess[i]] = Colors.white;
        } else {
          hintsC.add(Colors.white);
        }
      }
      localCombination.remove(guess[i]);
    }

    List<Color> cols = [];
    hints.values.toList().forEach((item) => cols.add(item));
    cols.addAll(hintsC);
    int nulls = currenCombination.length - cols.length;
    for (var i = 0; i < nulls; i++) {
      cols.add(Colors.black);
    }
    if (debug) {
      cols = currenCombination;
    }
    return cols;
  }
}
