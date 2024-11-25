import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'constants.dart';
import 'model/input_file.dart';
import 'services/match.dart';
import 'view/screens/flow.dart';

void main(List<String> args) {
  // create args paser and configure it
  ArgParser parser = ArgParser();
  parser.addFlag("help", defaultsTo: false);
  parser.addOption("extra");
  parser.addFlag("ff", defaultsTo: false);
  parser.addFlag("matrix", defaultsTo: false);

  // parse options and handle results
  ArgResults results = parser.parse(args);
  if (results.flag("help") || results.rest.length > 1) {
    // if help flag is set show help and exit
    _printUsage();
    exit(0);
  }

  String? inputFileName = results.rest.firstOrNull;
  String? extraPoints = results.option("extra");
  bool fastForwardMatch = results.flag("ff");
  bool showMatrices = results.flag("matrix");

  int? points = extraPoints != null ? int.tryParse(extraPoints) : null;

  /// service to handle input files
  final MatchService service = MatchService(
    // preload file from args if set
    file: inputFileName != null ? InputFile(inputFileName) : null,
    onError: (e) => toastification.show(
      type: ToastificationType.error,
      title: Text(
        e.toString(),
      ),
      style: kNotificationSytle,
      autoCloseDuration: kNotificationCloseDuration,
      showProgressBar: false,
      pauseOnHover: true,
    ),
    fastStart: fastForwardMatch,
    fastForward: fastForwardMatch,
    directMatchBonus: points ?? 10,
  );

  runApp(
    App(
      service: service,
      showMatrices: showMatrices || !fastForwardMatch,
    ),
  );
}

void _printUsage() => print("""
Usage:

  <executable> [OPTIONS] [FILE]

Options:
  --help                Show this usage information.
  --extra <number>      Specify an optional number of extra points for direct match (default: 10).
  --ff                  Enable fast mode, which skips as many interactions as possible.
  --matrix              When used with --ff, dont hide matrices.

Arguments:
  FILE                  (optional) The file to be used with the program. If omitted, the program provides a button to select a file.

Examples:
  Show usage information:
    <executable> --help
  
  Run with extra points for direct match:
    <executable> --extra 0
  
  Enable fast mode and display matrices:
    <executable> --ff --matrix
  
  Run with a file:
    <executable> --extra 5 --ff inputfile.csv
""");

class App extends StatelessWidget {
  /// service to handle input files and match the data
  final MatchService service;

  /// flag to show / hide matrices on screen
  final bool showMatrices;

  const App({
    super.key,
    required this.service,
    required this.showMatrices,
  });

  @override
  Widget build(BuildContext context) => ToastificationWrapper(
        config: const ToastificationConfig(
          alignment: Alignment.topRight,
        ),
        child: MaterialApp(
          title: "Belegium Matcher",
          theme: ThemeData(
            colorSchemeSeed: Colors.deepPurple,
            primaryColorDark: Colors.deepPurple.shade700,
            highlightColor: Colors.amber,
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: FlowScreen(
            service: service,
            showMatrices: showMatrices,
          ),
        ),
      );
}
