import 'package:flutter/material.dart';
import 'package:mastermind/Widget/CheckedStatus.dart';

import 'Circle.dart';

class CombinationRow extends StatefulWidget {
  List<Color> SelectedColors;
  int nThRow;
  final void Function(int i, int y) circleSelected;
  final List<Color> Function(int i) checkCombination;
  CombinationRow(this.SelectedColors, this.nThRow, this.circleSelected,
      this.checkCombination,
      {super.key});

  @override
  State<CombinationRow> createState() => _CombinationRowState();
}

class _CombinationRowState extends State<CombinationRow> {
  List<Widget> valueRow = [];
  bool checked = false;
  List<Color> hints = [];
  @override
  Widget build(BuildContext context) {
    valueRow = List.generate(
        4,
        (i) => InkWell(
            key: UniqueKey(),
            onTap: () {
              widget.circleSelected(widget.nThRow, i);
            },
            child: Circle(55, 55, widget.SelectedColors[i]))).toList();
    valueRow.add(InkWell(
        onTap: () {
          if (widget.SelectedColors.contains(Colors.grey)) {
            return;
          }

          setState(() {
            checked = true;
            hints = widget.checkCombination(widget.nThRow);
          });
        },
        child: SizedBox(
          height: 85,
          width: 85,
          child: CheckedStatus(checked, hints),
        )));
    return IgnorePointer(
      ignoring: checked,
      child: Row(children: valueRow),
    );
  }
}
