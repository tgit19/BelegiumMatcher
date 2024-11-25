import 'package:flutter/material.dart';

import '../../services/input.dart';
import '../widgets/table.dart';

class ErrorScreen extends StatelessWidget {
  final InputFileService fileService;

  const ErrorScreen({
    super.key,
    required this.fileService,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            fileService.error.toString(),
          ),
        ),
        body: Center(
          child: ListenableBuilder(
            listenable: fileService,
            builder: (context, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: TableWidget(
                          table: fileService.file!.table,
                          highlightPosition: fileService.error?.source,
                          highlightColor: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: fileService.loading ? null : fileService.reload,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cached),
                        SizedBox(width: 6),
                        Text("reload"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
