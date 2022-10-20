import 'package:flutter/material.dart';

import 'Widget/Exceptions.dart';
import 'dart:math';

class Controller {
  static const int nCombination = 4;
  bool debug = false;
  bool duplicates;
  Controller(this.duplicates) {
    genCombination();
  }
  List<Color> currenCombination = [];
  static const List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.white,
    Colors.green,
    Colors.black
  ];

  genCombination() {
    List<Color> comb = [];
    List<int> numbers = [];

    var rng = Random();
    for (var i = 0; i < 4; i++) {
      int rngs = rng.nextInt(6);
      if (!duplicates) {
        numbers.add(rngs);
        if (numbers.where((e) => e == rngs).length > 1) {
          i--;
          numbers.removeLast();
          continue;
        }
      }
      comb.add(colors[rngs]);
    }
    comb.shuffle();
    comb = [Colors.black, Colors.black, Colors.black, Colors.yellow];
    currenCombination = comb;
  }

  checkColors(List<Color> guess) {
    var hints = <dynamic, dynamic>{};
    List<Color> hintsC = [];
    List<Color> localCombination = List.from(currenCombination);
    int nRight = 0;
    for (var i = 0; i < currenCombination.length; i++) {
      // Correct color and position
      if (guess[i] == currenCombination[i]) {
        nRight++;
        if (hints[guess[i]] == Colors.green) {
          hintsC.add(Colors.green);
        } else {
          hints[guess[i]] = Colors.green;
        }
      } // Correct color wrong position
      else if (localCombination.contains(guess[i])) {
        if (hints[guess[i]] == Colors.green) {
          hintsC.add(Colors.white);
        } else {
          hints[guess[i]] = Colors.white;
        }
      }
      localCombination.remove(guess[i]);
    }
    if (nRight == nCombination) {
      throw WinException('WIN');
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
