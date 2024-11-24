import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'model/input_file.dart';
import 'services/input.dart';
import 'view/screens/error.dart';
import 'view/screens/input.dart';
import 'view/screens/results.dart';

void main(List<String> args) {
  runApp(
    App(inputFileName: args.firstOrNull),
  );
}

class App extends StatelessWidget {
  /// service to handle input files
  final InputFileService fileService;

  App({
    super.key,
    String? inputFileName,
  }) : fileService = InputFileService(
          file: inputFileName != null ? InputFile(inputFileName) : null,
        );

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
