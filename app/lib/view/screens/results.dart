import 'package:flutter/material.dart';

import '../../model/result.dart';
import '../../services/input.dart';
import '../widgets/assignment.dart';
import '../widgets/matrix.dart';
import '../widgets/table.dart';

class ResultsScreen extends StatelessWidget {
  final InputFileService fileService;

  const ResultsScreen({
    super.key,
    required this.fileService,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("solutions"),
        ),
        body: ListView(
          children: [
            Divider(),
            ListTile(
              title: Text(
                "input",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            ListTile(
              title: TableWidget(
                table: fileService.file!.table,
              ),
            ),
            for (AssignmentResult result in fileService.results)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(),
                  ListTile(
                    title: Text(
                      result.problemOperatrionDescription,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  ListTile(
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("max"),
                                      Icon(Icons.swap_horiz),
                                      Text("min"),
                                    ],
                                  ),
                                  Icon(
                                    Icons.trending_flat,
                                    size: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.fontSize,
                                  ),
                                  Text(
                                    result.costs.toString(),
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MatrixWidget(
                                result.problem!,
                                highlightPoints: result.assignments,
                              ),
                            ),
                            Expanded(
                              child: Wrap(
                                children: [
                                  for (MapEntry<int, int> assignment
                                      in result.assignments)
                                    if (assignment.key <
                                            fileService.persons.length &&
                                        assignment.value <
                                            fileService.wgs.length)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: fileService.wgMatrix![
                                                              assignment.key]
                                                          [assignment.value] <
                                                      0
                                                  ? Colors.red
                                                  : Colors.black,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.all(8.0),
                                          child: AssignmentWidget(
                                            wg: fileService
                                                .wgs[assignment.value],
                                            person: fileService
                                                .persons[assignment.key],
                                            wgScore: fileService
                                                    .wgMatrix![assignment.key]
                                                [assignment.value],
                                            personScore:
                                                fileService.personMatrix![
                                                        assignment.value]
                                                    [assignment.key],
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
          ],
        ),
      );
}
