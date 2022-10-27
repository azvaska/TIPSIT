import 'package:flutter/material.dart' show Color, Colors;

import 'Widget/exceptions.dart';
import 'dart:math';

class Controller {
  static const int nCombination = 4;
  final bool duplicates;
  List<Color> currenCombination = [];

  Controller(this.duplicates);
  static const List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.purple,
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
    List<Color> hintsC = [];
    //doppi bianchi
    List<Color> localCombination = List.from(currenCombination);
    List<Color> localGuess = List.from(guess);

    int nRight = 0;
    // Correct color and position
    for (int i = 0; i < currenCombination.length; i++) {
      if (guess[i] == currenCombination[i]) {
        nRight++;
        hintsC.add(Colors.green);
        localCombination.remove(guess[i]);
        localGuess.remove(guess[i]);
      }
    }
    if (nRight == nCombination) {
      throw WinException('WIN');
    }
    for (int i = 0; i < localGuess.length; i++) {
      // Correct color wrong position
      if (localCombination.contains(localGuess[i])) {
        hintsC.add(Colors.white);
      }
      localCombination.remove(localGuess[i]);
    }

    int nulls = currenCombination.length - hintsC.length;
    for (int i = 0; i < nulls; i++) {
      hintsC.add(Colors.black);
    }
    hintsC = currenCombination;
    return hintsC;
  }
}
