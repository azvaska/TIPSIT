import 'package:flutter/material.dart';
import 'package:mastermind/Widget/Board.dart';

void main() {
  runApp(const MasterMind());
}

class MasterMind extends StatelessWidget {
  const MasterMind({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mastermind',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const Board(),
    );
  }
}
