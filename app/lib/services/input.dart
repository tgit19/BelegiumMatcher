import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

import '../constants.dart';
import '../model/input_exception.dart';
import '../model/input_file.dart';
import '../model/matrix.dart';
import '../model/result.dart';
import '../model/solver.dart';
import 'hungarian.dart';

class InputFileService extends ChangeNotifier {
  /// instance of preferences
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// file to work with
  InputFile? file;

  /// internal semaphore for [_load]
  bool _loading = false;
  bool get loading => _loading;

  /// used solver
  AssignmentSolver<int> _solver = HungarianSolver();
  set solver(AssignmentSolver<int> solver) => _solver = solver;

  /// internal semaphore for [match]
  bool _matching = false;
  bool get matching => _matching;

  /// cached value for the direct match bonus
  int? _directMatchBonus;

  Matrix<int>? wgMatrix;
  Matrix<int>? personMatrix;

  List<String> get wgs => file!.wgs;
  List<String> get persons => file!.persons;

  /// matching results get added to this list
  final List<AssignmentResult> results = [];

  /// store details of errors
  InputException? error;

  InputFileService({
    this.file,
  }) {
    if (file != null) {
      unawaited(
        _load(),
      );
    }

    unawaited(
      getDirectMatchBonus(),
    );
  }

  /// internal storage for merge strategies of matrices
  final Map<String, int Function(int, int)> _combinationFunctions = {
    "a + b": (a, b) => a + b,
    "a * b": (a, b) => a * b,
    "sign(a) * sign(b) * a * b": (a, b) => ((a < 0 || b < 0) ? -1 : 1) * a * b,
    "a + b - abs(a - b) / 3": (a, b) => (a + b - (a - b).abs() / 3).toInt(),
  };

  /// method to select a file
  Future<Exception?> selectFile() async {
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

    // user pushed abort
    if (filepath == null) return null;

    // set file and load content
    file = InputFile(filepath);
    await _load();

    // return error
    return error;
  }

  /// method to reload a selected file
  /// \return if file was cached
  Future<bool> reload() async {
    if (file == null) return false;

    // load file
    await _load();
    return true;
  }

  /// method to start the matching
  Future<void> match([Map<int, int>? wgRooms]) async {
    if (_matching) return;
    _matching = true;

    // delete old results
    results.clear();
    notifyListeners();

    // adjust values for vetos and perfect matches
    await _processExtrema();

    if (wgRooms != null) {
      // copy wg if there are multiple empty rooms
      for (int wg in wgRooms.keys) {
        for (int i = 1; i < wgRooms[wg]!; i++) {
          // copy column of wg
          wgMatrix = wgMatrix!.addColumns(
            wgMatrix!.column(wg),
          );

          // copy row for persons
          personMatrix = personMatrix!.addRows(
            personMatrix!.row(wg),
          );

          // add wg name again to wg string list
          file!.wgs.add(file!.wgs[wg]);
        }
      }
    }

    // make matrices quadratic
    if (!wgMatrix!.dimension.isQuadratic) {
      wgMatrix = wgMatrix!.quadratic(-100);
    }

    if (!personMatrix!.dimension.isQuadratic) {
      personMatrix = personMatrix!.quadratic(-100);
    }

    // perform match
    for (var fkt in _combinationFunctions.keys) {
      // define problem
      Matrix<int> problem = _invertProblem(
        wgMatrix!.combine(
          personMatrix!.transpose(),
          _combinationFunctions[fkt]!,
        ),
      );

      results.add(
        _solver.solve(problem)..problemOperatrionDescription = fkt,
      );
    }

    _matching = false;
    notifyListeners();
  }

  /// method to get direct match bonus from preferences
  Future<int> getDirectMatchBonus() async {
    // return cached value
    if (_directMatchBonus != null) return _directMatchBonus!;

    SharedPreferences preferences = await _prefs;

    // cache value and return it
    _directMatchBonus = preferences.getInt("directBonus") ?? 10;
    notifyListeners();
    return _directMatchBonus!;
  }

  /// method to set direct match bonus as preference
  Future<bool> setDirectMatchBonus(int value) async {
    SharedPreferences preferences = await _prefs;

    // cache value
    _directMatchBonus = value;
    notifyListeners();

    // return if save is successful
    return preferences.setInt("directBonus", value);
  }

  /// internal method to load tables
  Future<void> _load() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();

    // clear old error
    error = null;

    try {
      List<Matrix<int>> tables = await file!.load();
      wgMatrix = tables.first;
      personMatrix = tables.last;
    } on FileSystemException catch (e) {
      toastification.show(
        type: ToastificationType.error,
        title: Text(
          e.toString(),
        ),
        style: kNotificationSytle,
        autoCloseDuration: kNotificationCloseDuration,
        showProgressBar: false,
        pauseOnHover: true,
      );
    } on InputException catch (e) {
      // handle error notification elsewhere
      error = e;
      notifyListeners();
    } on FormatException catch (e) {
      toastification.show(
        type: ToastificationType.error,
        title: Text(
          e.toString(),
        ),
        style: kNotificationSytle,
        autoCloseDuration: kNotificationCloseDuration,
        showProgressBar: false,
        pauseOnHover: true,
      );
    } on Exception catch (e) {
      print("Unknown exception: $e");

      // rethrow all unhandle exceptions
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// internal method to modify extrema
  Future<void> _processExtrema() async {
    // load match bonus if unset
    if (_directMatchBonus == null) {
      await getDirectMatchBonus();
    }

    // adjust values for vetos and perfect matches
    for (int i = 0; i < wgMatrix!.dimension.m; i++) {
      for (int j = 0; j < wgMatrix!.dimension.n; j++) {
        if (wgMatrix![i][j] == 0 || personMatrix![j][i] == 0) {
          wgMatrix![i][j] = -100;
          personMatrix![j][i] = -100;
        } else if (wgMatrix![i][j] == 15 || personMatrix![j][i] == 15) {
          wgMatrix![i][j] += _directMatchBonus!;
          personMatrix![j][i] += _directMatchBonus!;
        }
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
