import 'package:args/args.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'model/input_file.dart';
import 'services/input.dart';
import 'view/screens/error.dart';
import 'view/screens/input.dart';
import 'view/screens/results.dart';

void main(List<String> args) {
  // create args paser and configure it
  ArgParser parser = ArgParser();
  parser.addOption("extra");

  // parse options and handle results
  ArgResults results = parser.parse(args);
  String? inputFileName = results.rest.firstOrNull;
  String? extraPoints = results.option("extra");

  /// service to handle input files
  final InputFileService fileService = InputFileService(
    // preload file from args if set
    file: inputFileName != null ? InputFile(inputFileName) : null,
  );

  if (extraPoints != null) {
    int? points = int.tryParse(extraPoints);
    if (points != null) {
      fileService.setDirectMatchBonus(points);
    }
  }

  runApp(
    App(fileService: fileService),
  );
}

class App extends StatelessWidget {
  /// service to handle input files
  final InputFileService fileService;

  const App({
    super.key,
    required this.fileService,
  });

  @override
  Widget build(BuildContext context) => ToastificationWrapper(
        config: const ToastificationConfig(
          alignment: Alignment.topLeft,
        ),
        child: MaterialApp(
          title: "Belegium Matcher",
          theme: ThemeData(
            colorSchemeSeed: Colors.deepPurple,
            primaryColorDark: Colors.deepPurple.shade700,
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: "/input",
          routes: {
            "/input": (_) => InputScreen(fileService: fileService),
            "/error": (_) => ErrorScreen(fileService: fileService),
            "/results": (_) => ResultsScreen(fileService: fileService),
          },
        ),
      );
}
