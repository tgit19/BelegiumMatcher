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
  parser.addFlag("ff", defaultsTo: false);

  // parse options and handle results
  ArgResults results = parser.parse(args);
  String? inputFileName = results.rest.firstOrNull;
  String? extraPoints = results.option("extra");
  bool fastForwardMatch = results.flag("ff");

  /// service to handle input files
  final InputFileService fileService = InputFileService(
    // preload file from args if set
    file: inputFileName != null ? InputFile(inputFileName) : null,
    fastForwardMatch: fastForwardMatch,
  );

  if (extraPoints != null) {
    int? points = int.tryParse(extraPoints);
    if (points != null) {
      fileService.setDirectMatchBonus(points);
    }
  }

  /// private sub function to start app after matching on fast forward
  void ffStartApp() {
    if (!(fileService.loading || fileService.matching)) {
      fileService.removeListener(ffStartApp);
      runApp(
        App(fileService: fileService),
      );
    }
  }

  if (inputFileName != null && fastForwardMatch) {
    fileService.addListener(ffStartApp);
  } else {
    runApp(
      App(fileService: fileService),
    );
  }
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
            highlightColor: Colors.amber,
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: fileService.error != null
              ? "/error"
              : fileService.results.isNotEmpty
                  ? "/results"
                  : "/input",
          routes: {
            "/input": (_) => InputScreen(fileService: fileService),
            "/error": (_) => ErrorScreen(fileService: fileService),
            "/results": (_) => ResultsScreen(fileService: fileService),
          },
        ),
      );
}
