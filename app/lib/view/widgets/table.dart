import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/matrix_storage.dart';
import '../../model/table_position.dart';

/// widget to display the input table and hightlight errors
class TableWidget extends StatelessWidget {
  /// table containig data to display
  final MatrixStorage<String> table;

  /// optional position to indicate error
  final TablePosition? highlightPosition;

  /// optional color for errors
  final Color? highlightColor;

  /// constructor for table scenes
  const TableWidget({
    super.key,
    required this.table,
    this.highlightPosition,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) => Table(
        border: TableBorder.all(
          color: Theme.of(context).dividerColor,
        ),
        children: [
          for (int i = 0; i < table.length; i++)
            TableRow(
              children: [
                for (int j = 0; j < table[i].length; j++)
                  Container(
                    color: (highlightPosition?.row == i &&
                                highlightPosition?.column == null) ||
                            (highlightPosition?.row == null &&
                                (highlightPosition?.rowOffset ?? 0) <= i &&
                                highlightPosition?.column == j) ||
                            (highlightPosition?.row == i &&
                                highlightPosition?.column == j)
                        ? highlightColor ?? Theme.of(context).colorScheme.error
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        table[i][j],
                      ),
                    ),
                  ),
                for (int j = table[i].length; j < tableWidth(); j++)
                  const SizedBox(),
              ],
            ),
        ],
      );

  /// internal method to calculate table width
  int tableWidth() {
    int width = 0;

    for (List<String> row in table) {
      width = max(width, row.length);
    }

    return width;
  }
}
