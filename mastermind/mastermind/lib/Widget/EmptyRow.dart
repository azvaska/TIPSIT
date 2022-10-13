import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'Circle.dart';

class CombinationRow extends StatefulWidget {
  const CombinationRow({super.key});

  @override
  State<CombinationRow> createState() => _CombinationRowState();
}

class _CombinationRowState extends State<CombinationRow> {
  static const List<Color> valueRow = [
    Colors.grey,
    Colors.grey,
    Colors.grey,
    Colors.grey
  ];
  @override
  Widget build(BuildContext context) {
    return Row(
        children: List.generate(
            valueRow.length,
            (i) => InkWell(
                onTap: () => {}, child: Circle(55, 55, valueRow[i]))).toList());
  }
}
