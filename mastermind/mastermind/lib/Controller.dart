import 'package:flutter/material.dart';

import 'Widget/Exceptions.dart';

class Controller {
  static const int nCombination = 4;
  Controller() {
    genCombination();
  }
  var currenCombination = [];
  static const List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.white,
    Colors.green,
    Colors.black
  ];
  static const List<Color> defaultHintsColor = [
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black
  ];
  genCombination() {
    var comb = currenCombination = List.from(colors);
    comb.shuffle();
    comb = comb.sublist(0, 4);
    currenCombination = comb;
    for (Color c in currenCombination) {
      print(c);
    }
  }

  checkColors(List<Color> guess) {
    List<Color> hints = List.from(defaultHintsColor);
    int nRight = 0;
    for (var i = 0; i < currenCombination.length; i++) {
      // Correct color & position
      if (guess[i] == currenCombination[i]) {
        // Use RED since board has a dark background
        hints[i] = Colors.green;
        nRight++;
      } // Correct color, wrong position
      else if (currenCombination.contains(guess[i])) {
        hints[i] = Colors.white;
      }
    }
    if (nRight == nCombination) {
      throw WinException('WIN');
    }
    return hints;
  }
}
