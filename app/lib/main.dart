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
  parser.addOption("extra");
  parser.addFlag("ff", defaultsTo: false);

  // parse options and handle results
  ArgResults results = parser.parse(args);
  String? inputFileName = results.rest.firstOrNull;
  String? extraPoints = results.option("extra");
  bool fastForwardMatch = results.flag("ff");

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
    App(service: service),
  );
}

class App extends StatelessWidget {
  /// service to handle input files and match the data
  final MatchService service;

  const App({
    super.key,
    required this.service,
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
          ),
        ),
      );
}
