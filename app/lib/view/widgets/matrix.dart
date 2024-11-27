import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/matrix.dart';

/// widget to display a matrix
class MatrixWidget extends StatelessWidget {
  final Matrix matrix;
  final List<MapEntry<int, int>> highlightPoints;
  final Color? highlightColor;
  final Color? inactiveColor;

  const MatrixWidget(
    this.matrix, {
    super.key,
    this.highlightPoints = const [],
    this.highlightColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize = Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14;
    num maxChars = log(matrix.largestEntry()) / log(10) + 1;

    return Container(
      width: fontSize * maxChars * (matrix.dimension.m + 1),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.black, width: 2),
          right: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Table(
        children: [
          for (int i = 0; i < matrix.dimension.m; i++)
            TableRow(
              children: [
                for (int j = 0; j < matrix.dimension.n; j++)
                  Builder(
                    builder: (context) {
                      Color? hightLight;

                      for (var entry in highlightPoints) {
                        if (entry.key == i && entry.value == j) {
                          hightLight = highlightColor ??
                              Theme.of(context).highlightColor;
                          break;
                        }
                      }

                      return Text(
                        matrix[i][j].toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: highlightPoints.isEmpty
                              ? null
                              : hightLight ??
                                  inactiveColor ??
                                  Theme.of(context).disabledColor,
                        ),
                      );
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
