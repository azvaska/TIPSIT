import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

class Controller {
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
  genCombination() {
    var comb = currenCombination = List.from(colors);
    comb.shuffle();
  }
}
