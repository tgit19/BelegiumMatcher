import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

import '../model/input_file.dart';
import '../model/matrix.dart';
import '../model/result.dart';
import '../model/solver.dart';
import 'hungarian.dart';

class MatchService extends ChangeNotifier {
  // file holding the data to work with
  InputFile? _file;
  InputFile? get file => _file;

  /// callback if errors occur
  final void Function(dynamic exception)? onError;

  /// flag wether to skip step 3
  final bool fastForward;

  /// bonus for direct matches
  final int directMatchBonus;

  /// flag to prevent multiple runs at once
  bool _running = false;
  bool get running => _running;

  /// variable to monitor matching progress
  int _activeStep = 0;
  int get activeStep => _activeStep;

  // loaded tables from file
  List<Matrix<int>>? _tables;
  List<Matrix<int>>? get tables => _tables;

  // first matrix from file
  Matrix<int>? _matrixA;
  Matrix<int>? get matrixA => _matrixA;

  // second matrix from file
  Matrix<int>? _matrixB;
  Matrix<int>? get matrixB => _matrixB;

  // headers of the tables
  final List<String> matrixRowHeaderA = [];
  final List<String> matrixRowHeaderB = [];

  // maps for duplicates of the headers
  final Map<int, int> matrixRowHeaderMapA = {};
  final Map<int, int> matrixRowHeaderMapB = {};

  /// internal storage for merge strategies of matrices
  final Map<String, int Function(int, int)> _combinationFunctions = {
    "a + b": (a, b) => a + b,
    "a * b": (a, b) => a * b,
    "sign(a) * sign(b) * a * b": (a, b) => ((a < 0 || b < 0) ? -1 : 1) * a * b,
    "a + b - abs(a - b) / 3": (a, b) => (a + b - (a - b).abs() / 3).toInt(),
  };
  Iterable<String> get combinationFunctionDescriptions =>
      _combinationFunctions.keys;

  /// matrices of the problems [max, min]
  final List<MapEntry<Matrix<int>, Matrix<int>>> problems = [];

  /// used solver
  final AssignmentSolver<int> _solver = HungarianSolver();

  /// solutions of the min problems
  final List<AssignmentResult> solutions = [];

  MatchService({
    InputFile? file,
    this.onError,
    this.fastForward = false,
    this.directMatchBonus = 10,
    bool fastStart = false,
  })  : _file = file,
        _activeStep = file != null ? 1 : 0 {
    if (fastStart || file != null) {
      unawaited(
        run(),
      );
    }
  }

  /// method to perform the match
  Future<void> run([int? step]) async {
    // prevent multiple runs at once
    if (_running) return;
    _running = true;

    // set step to contiue with
    if (step != null && step < _activeStep) {
      _activeStep = step;
    } else if (_activeStep == 2) {
      _activeStep++;
    }

    // notify listernes about new [running] (and [activeStep]) stati
    notifyListeners();

    // run the matching steps
    await _runSteps();

    // notify done
    _running = false;
    notifyListeners();
  }

  /// internal method to run the actual matching steps
  Future<void> _runSteps() async {
    // select file
    if (_activeStep == 0) {
      await _selectFile();
      if (_file != null) {
        _continue(1);
      }
    }

    // load file content
    if (_activeStep == 1) {
      await _load();
      if (_file!.error == null) {
        _continue(1);
      } else {
        // abort on error
        return;
      }
    }

    // duplicate columns
    if (_activeStep == 2) {
      if (fastForward) {
        // silently continue to next step
        _activeStep++;
      } else {
        // wait for user input
        return;
      }
    }

    // transform data
    if (_activeStep == 3) {
      await _processExtrema();
      _copyColumns();

      // make matrices quadratic
      if (!_matrixA!.dimension.isQuadratic) {
        _matrixA = _matrixA!.quadratic(-100);
      }

      if (!_matrixB!.dimension.isQuadratic) {
        _matrixB = _matrixB!.quadratic(-100);
      }

      _continue(1);
    }

    // match
    if (_activeStep == 4) {
      // remove old problems
      problems.clear();
      solutions.clear();

      for (int i = 0; i < combinationFunctionDescriptions.length; i++) {
        // get string describing the problem merge operation
        String problemOperatrionDescription =
            combinationFunctionDescriptions.elementAt(i);

        // define max problem
        Matrix<int> problem = _matrixA!.combine(
          _matrixB!.transpose(),
          _combinationFunctions[problemOperatrionDescription]!,
        );

        // define min problem
        Matrix<int> inverseProblem = _invertProblem(problem);

        // add problems
        problems.add(
          MapEntry(
            problem,
            inverseProblem,
          ),
        );

        // add solution
        solutions.add(
          _solver.solve(
            inverseProblem,
          )..problemOperatrionDescription = problemOperatrionDescription,
        );
      }

      // finished
      _continue(1);
    }
  }

  /// internal helper method to increment [activeStep] by [stepSize] and notify listeners
  void _continue(int stepSize) {
    _activeStep += stepSize;
    notifyListeners();
  }

  /// internal method to select a new file
  Future<void> _selectFile() async {
    // start file picker for user to select a file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      initialDirectory: '.',
      type: FileType.custom,
      allowedExtensions: ["csv"],
      allowMultiple: false,
      lockParentWindow: true,
    );

    // get file path from result
    String? filepath = result?.files.firstOrNull?.path;

    // set file
    _file = filepath == null ? null : InputFile(filepath);
  }

  /// internal method to load tables
  Future<void> _load() async {
    // clear old headers
    matrixRowHeaderA.clear();
    matrixRowHeaderB.clear();
    matrixRowHeaderMapA.clear();
    matrixRowHeaderMapB.clear();

    try {
      // load tables
      _tables = await _file!.load();

      // copy matrices to work with
      _matrixA = tables?[0].copy();
      _matrixB = tables?[1].copy();

      // initalize header A and its map
      for (int i = 0; i < _file!.wgs.length; i++) {
        matrixRowHeaderA.add(_file!.wgs[i]);
        matrixRowHeaderMapA[i] = 1;
      }

      // initalize header B and its map
      for (int i = 0; i < _file!.persons.length; i++) {
        matrixRowHeaderB.add(_file!.persons[i]);
        matrixRowHeaderMapB[i] = 1;
      }
    } catch (e) {
      if (onError != null) {
        onError!(e);
      } else {
        // rethrow all unhandle exceptions
        rethrow;
      }
    }
  }

  /// internal method to modify extrema
  Future<void> _processExtrema() async {
    // adjust values for vetos and perfect matches
    for (int i = 0; i < matrixA!.dimension.m; i++) {
      for (int j = 0; j < matrixA!.dimension.n; j++) {
        if (matrixA![i][j] == 0 || matrixB![j][i] == 0) {
          matrixA![i][j] = -100;
          matrixB![j][i] = -100;
        } else if (matrixA![i][j] == 15 || matrixB![j][i] == 15) {
          matrixA![i][j] += directMatchBonus;
          matrixB![j][i] += directMatchBonus;
        }
      }
    }
  }

  /// internal method to copy columns if there should be multiple matches to one entry
  void _copyColumns() {
    // copy A.column() if needed
    for (int n in matrixRowHeaderMapA.keys) {
      for (int i = 1; i < matrixRowHeaderMapA[n]!; i++) {
        // copy column of A
        _matrixA = _matrixA!.addColumns(
          matrixA!.column(n),
        );

        // copy row for B
        _matrixB = _matrixB!.addRows(
          matrixB!.row(n),
        );

        // add entry name again to the list
        matrixRowHeaderA.add(matrixRowHeaderA[n]);
      }
    }

    // copy B.column() if needed
    for (int n in matrixRowHeaderMapB.keys) {
      for (int i = 1; i < matrixRowHeaderMapB[n]!; i++) {
        // copy column of A
        _matrixB = _matrixB!.addColumns(
          _matrixB!.column(n),
        );

        // copy row for B
        _matrixA = _matrixA!.addRows(
          matrixA!.row(n),
        );

        // add entry name again to the list
        matrixRowHeaderB.add(matrixRowHeaderB[n]);
      }
    }
  }

  /// internal method to make minimize problem out of maximize problem
  Matrix<int> _invertProblem(Matrix<int> problem) =>
      Matrix(
        problem.dimension,
        fillValue: problem.largestEntry(),
      ) -
      problem;
}
