import 'package:flutter/material.dart';

import '../../services/input.dart';
import '../scenes/table.dart';

class InputScreen extends StatelessWidget {
  final InputFileService fileService;

  const InputScreen({
    super.key,
    required this.fileService,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ListenableBuilder(
            listenable: fileService,
            builder: (context, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (fileService.file != null && fileService.error == null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SingleChildScrollView(
                          child: TableScene(
                            table: fileService.file!.table,
                          ),
                        ),
                      ),
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 8.0,
                      ),
                      child: ElevatedButton(
                        onPressed: fileService.loading
                            ? null
                            : () => fileService.selectFile().then(
                                  (value) {
                                    if (value != null) {
                                      Navigator.maybeOf(context)
                                          ?.pushNamed("/error");
                                    }
                                  },
                                ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.file_open_outlined),
                            SizedBox(width: 6),
                            Text("open"),
                          ],
                        ),
                      ),
                    ),
                    if (fileService.error == null &&
                        fileService.personMatrix != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 8.0,
                        ),
                        child: ElevatedButton(
                          onPressed: fileService.matching
                              ? null
                              : () => fileService.match().then(
                                    (value) {
                                      Navigator.maybeOf(context)
                                          ?.pushNamed("/results");
                                    },
                                  ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow_outlined),
                              SizedBox(width: 6),
                              Text("match"),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
