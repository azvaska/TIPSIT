import 'package:flutter/material.dart';
import 'package:mastermind/Widget/CheckedStatus.dart';

import 'Circle.dart';

class CombinationRow extends StatefulWidget {
  final List<Color> selectedColors;
  final int nThRow;
  final void Function(int i, int y) circleSelected;
  final List<Color> Function(int i) checkCombination;
  const CombinationRow(this.selectedColors, this.nThRow, this.circleSelected,
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
            child: Circle(55, 55, widget.selectedColors[i]))).toList();
    valueRow.add(InkWell(
        onTap: () {
          if (widget.selectedColors.contains(Colors.grey)) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text("You need to fill all circles with color"),
            ));
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
