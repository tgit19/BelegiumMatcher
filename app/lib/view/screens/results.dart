import 'package:flutter/material.dart';

import '../../model/result.dart';
import '../../services/input.dart';
import '../widgets/assignment.dart';

class ResultsScreen extends StatelessWidget {
  final InputFileService fileService;

  const ResultsScreen({
    super.key,
    required this.fileService,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: [
            for (AssignmentResult result in fileService.results)
              ListTile(
                leading: Text(result.costs.toString()),
                title: Wrap(
                  children: [
                    for (MapEntry<int, int> assignment in result.assignments)
                      if (assignment.key < fileService.wgs.length &&
                          assignment.value < fileService.persons.length)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: AssignmentWidget(
                              wg: fileService.wgs[assignment.key],
                              person: fileService.persons[assignment.value],
                              wgScore:
                                  fileService.personMatrix![assignment.value]
                                      [assignment.key],
                              personScore: fileService.wgMatrix![assignment.key]
                                  [assignment.value],
                            ),
                          ),
                        ),
                  ],
                ),
              )
          ],
        ),
      );
}
