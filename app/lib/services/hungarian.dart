import 'dart:math';

import '../model/matrix.dart';
import '../model/result.dart';
import '../model/solver.dart';

class HungarianSolver extends AssignmentSolver<int> {
  late Matrix<int> matrix;
  late Matrix<int> mask;
  List<int> rowCover = [];
  List<int> colCover = [];

  int pathRow0 = 0;
  int pathCol0 = 0;

  int get size => matrix.dimension.n;

  @override
  AssignmentResult solve(Matrix<int> problem) {
    if (!problem.dimension.isQuadratic || problem.dimension.n < 2) {
      throw ArgumentError("Invalid problem size (${problem.dimension}).");
    }

    // initialize data
    matrix = problem.copy();
    mask = Matrix(problem.dimension);
    rowCover.clear();
    colCover.clear();

    for (int i = 0; i < problem.dimension.n; i++) {
      rowCover.add(0);
      colCover.add(0);
    }

    bool done = false;
    int step = 1;
    while (!done) {
      switch (step) {
        case 1:
          step = _step1();
          break;
        case 2:
          step = _step2();
          break;
        case 3:
          step = _step3();
          break;
        case 4:
          step = _step4();
          break;
        case 5:
          step = _step5();
          break;
        case 6:
          step = _step6();
          break;
        case 7:
          done = true;
          break;
      }
    }

    AssignmentResult result = AssignmentResult(problem);

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (mask[i][j] == 1) {
          result.costs += problem[i][j];
          result.assignments.add(
            MapEntry<int, int>(i, j),
          );
        }
      }
    }

    return result;
  }

  /// internal method for solving step 1
  int _step1() {
    for (int r = 0; r < size; ++r) {
      int minVal = double.maxFinite.toInt();
      for (int c = 0; c < size; ++c) {
        minVal = min(minVal, matrix[r][c]);
      }

      for (int c = 0; c < size; ++c) {
        matrix[r][c] -= minVal;
      }
    }

    for (int c = 0; c < size; ++c) {
      int minVal = double.maxFinite.toInt();
      for (int r = 0; r < size; ++r) {
        minVal = min(minVal, matrix[r][c]);
      }

      for (int r = 0; r < size; ++r) {
        matrix[r][c] -= minVal;
      }
    }

    // continue with [step2]
    return 2;
  }

  /// internal method for solving step 2
  int _step2() {
    for (int r = 0; r < size; ++r) {
      for (int c = 0; c < size; ++c) {
        if (matrix[r][c] == 0 && rowCover[r] == 0 && colCover[c] == 0) {
          rowCover[r] = 1;
          colCover[c] = 1;
          mask[r][c] = 1;
        }
      }
    }

    rowCover.fillRange(0, rowCover.length, 0);
    colCover.fillRange(0, colCover.length, 0);

    return 3;
  }

  /// internal method for solving step 3
  int _step3() {
    int count = 0;
    for (int r = 0; r < size; ++r) {
      for (int c = 0; c < size; ++c) {
        if (mask[r][c] == 1 && colCover[c] == 0) {
          colCover[c] = 1;
          ++count;
        }
      }
    }

    return count >= size ? 7 : 4;
  }

  /// internal method for solving step 4
  int _step4() {
    int row = -1;
    int col = -1;
    bool done = false;

    while (!done) {
      MapEntry<int, int>? uncoveredZero = _findUncoveredZero();

      if (uncoveredZero == null) {
        return 6;
      } else {
        row = uncoveredZero.key;
        col = uncoveredZero.value;
        mask[row][col] = 2;
        int starCol = _findStarInRow(row);
        if (starCol != -1) {
          col = starCol;
          rowCover[row] = 1;
          colCover[col] = 0;
        } else {
          pathRow0 = row;
          pathCol0 = col;
          return 5;
        }
      }
    }
  }

  /// internal method for solving step 5
  int _step5() {
    bool done = false;
    int r = -1;
    int c = -1;

    List<MapEntry> path = [];
    path.add(MapEntry(pathRow0, pathCol0));
    while (!done) {
      r = _findStarInCol(path.last.value);
      if (r > -1) {
        path.add(
          MapEntry(r, path.last.value),
        );
      } else {
        done = true;
      }

      if (!done) {
        c = _findPrimeInRow(path.last.key);
        path.add(
          MapEntry(path.last.key, c),
        );
      }
    }

    _augmentPath(path);
    rowCover.fillRange(0, rowCover.length, 0);
    colCover.fillRange(0, colCover.length, 0);
    _clearPrimes();

    return 3;
  }

  /// internal method for solving step 6
  int _step6() {
    int minVal = _findSmallestUncovered();
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (rowCover[r] == 1) matrix[r][c] += minVal;
        if (colCover[c] == 0) matrix[r][c] -= minVal;
      }
    }

    return 4;
  }

  void _augmentPath(List<MapEntry> path) {
    for (MapEntry p in path) {
      mask[p.key][p.value] = (mask[p.key][p.value] == 1) ? 0 : 1;
    }
  }

  void _clearPrimes() {
    for (int r = 0; r < size; ++r) {
      for (int c = 0; c < size; ++c) {
        if (mask[r][c] == 2) {
          mask[r][c] = 0;
        }
      }
    }
  }

  int _findPrimeInRow(int row) {
    for (int c = 0; c < size; ++c) {
      if (mask[row][c] == 2) {
        return c;
      }
    }

    return -1;
  }

  int _findSmallestUncovered() {
    int minVal = double.maxFinite.toInt();

    for (int r = 0; r < size; ++r) {
      for (int c = 0; c < size; ++c) {
        if (rowCover[r] == 0 && colCover[c] == 0) {
          minVal = min(minVal, matrix[r][c]);
        }
      }
    }

    return minVal;
  }

  int _findStarInCol(int col) {
    for (int r = 0; r < size; ++r) {
      if (mask[r][col] == 1) {
        return r;
      }
    }

    return -1;
  }

  int _findStarInRow(int row) {
    for (int c = 0; c < size; ++c) {
      if (mask[row][c] == 1) {
        return c;
      }
    }

    return -1;
  }

  MapEntry<int, int>? _findUncoveredZero() {
    for (int r = 0; r < size; ++r) {
      for (int c = 0; c < size; ++c) {
        if (matrix[r][c] == 0 && rowCover[r] == 0 && colCover[c] == 0) {
          return MapEntry(r, c);
        }
      }
    }

    return null;
  }
}
