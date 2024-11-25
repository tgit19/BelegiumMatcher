import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';

import '../../services/match.dart';
import '../widgets/assignment.dart';
import '../widgets/matrix.dart';
import '../widgets/section.dart';
import '../widgets/table.dart';

class FlowScreen extends StatelessWidget {
  /// service to perform matches
  final MatchService service;

  const FlowScreen({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListenableBuilder(
        listenable: service,
        builder: (context, _) => ListView(
          children: [
            SectionWidget(
              title: "1) select file",
              titleStaus: service.activeStep == 0
                  ? Icon(Icons.file_open_outlined)
                  : 0 < service.activeStep
                      ? Icon(Icons.done)
                      : CircularProgressIndicator(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 8.0,
                        ),
                        child: ElevatedButton(
                          onPressed:
                              service.running ? null : () => service.run(0),
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
                      if (service.file != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 8.0,
                          ),
                          child: ElevatedButton(
                            onPressed:
                                service.running ? null : () => service.run(1),
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
                ],
              ),
            ),
            if (service.activeStep >= 1)
              SectionWidget(
                title: "2) load file content",
                titleStaus: service.file?.error != null
                    ? Icon(Icons.error_outline)
                    : 1 < service.activeStep
                        ? Icon(Icons.done)
                        : CircularProgressIndicator(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (service.file?.table.isNotEmpty ?? false)
                      TableWidget(
                        table: service.file!.table,
                        highlightPosition: service.file!.error?.source,
                      ),
                    if (service.file!.error != null)
                      Text(
                        service.file!.error.toString(),
                      ),
                  ],
                ),
              ),
            if (service.activeStep >= 2 && !service.fastForward)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SectionWidget(
                    title: "3.a) duplicate A columns",
                    titleStaus: 2 < service.activeStep
                        ? Icon(Icons.done)
                        : Icon(Icons.edit),
                    child: Wrap(
                      children: [
                        for (int i = 0;
                            i < service.file!.wgs.toSet().length;
                            i++)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InputQty.int(
                              initVal: service.matrixRowHeaderMapA[i]!,
                              minVal: 1,
                              decoration: QtyDecorationProps(
                                leadingWidget: Text(
                                  service.file!.wgs[i],
                                ),
                                qtyStyle: QtyStyle.btnOnRight,
                              ),
                              onQtyChanged: (value) =>
                                  service.matrixRowHeaderMapA[i] = value,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SectionWidget(
                    title: "3.b) duplicate B columns",
                    titleStaus: 2 < service.activeStep
                        ? Icon(Icons.done)
                        : Icon(Icons.edit),
                    child: Wrap(
                      children: [
                        for (int i = 0;
                            i < service.file!.persons.toSet().length;
                            i++)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InputQty.int(
                              initVal: service.matrixRowHeaderMapB[i]!,
                              minVal: 1,
                              decoration: QtyDecorationProps(
                                leadingWidget: Text(
                                  service.file!.persons[i],
                                ),
                                qtyStyle: QtyStyle.btnOnRight,
                              ),
                              onQtyChanged: (value) =>
                                  service.matrixRowHeaderMapB[i] = value,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (service.activeStep == 2)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 8.0,
                          ),
                          child: ElevatedButton(
                            onPressed: service.running ? null : service.run,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_arrow),
                                SizedBox(width: 6),
                                Text("continue"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            if (service.activeStep >= 3)
              SectionWidget(
                title: "4) transform data",
                titleStaus: 3 < service.activeStep
                    ? Icon(Icons.done)
                    : CircularProgressIndicator(),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16.0,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("A = "),
                        MatrixWidget(service.matrixA!),
                      ],
                    ),
                    Text(','),
                    SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("B = "),
                        MatrixWidget(service.matrixB!),
                      ],
                    ),
                  ],
                ),
              ),
            if (service.activeStep >= 4)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // loop through strategies
                  for (int i = 0;
                      i < service.combinationFunctionDescriptions.length;
                      i++)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SectionWidget(
                          title:
                              "5.${i + 1}) ${service.combinationFunctionDescriptions.elementAt(i)}",
                          titleStaus: Text(
                            service.solutions.elementAt(i).costs.toString(),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 16.0,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("M = "),
                                          MatrixWidget(
                                            service.problems[i].key,
                                            highlightPoints: service.solutions
                                                    .elementAtOrNull(i)
                                                    ?.assignments ??
                                                const [],
                                          ),
                                          Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
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
                                                ],
                                              ),
                                            ),
                                          ),
                                          Text("W = "),
                                          MatrixWidget(
                                            service.problems[i].value,
                                            highlightPoints: service.solutions
                                                    .elementAtOrNull(i)
                                                    ?.assignments ??
                                                const [],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8.0,
                                    ),
                                    Wrap(
                                      children: [
                                        for (MapEntry<int, int> assignment
                                            in service.solutions[i].assignments)
                                          if (assignment.key <
                                                  service.matrixRowHeaderB
                                                      .length &&
                                              assignment.value <
                                                  service
                                                      .matrixRowHeaderA.length)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: service.matrixA![
                                                                    assignment
                                                                        .key][
                                                                assignment
                                                                    .value] <
                                                            0
                                                        ? Colors.red
                                                        : Colors.black,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsets.all(8.0),
                                                child: AssignmentWidget(
                                                  a: service.matrixRowHeaderB[
                                                      assignment.key],
                                                  b: service.matrixRowHeaderA[
                                                      assignment.value],
                                                  aScore: service.matrixA![
                                                          assignment.key]
                                                      [assignment.value],
                                                  bScore: service.matrixB![
                                                          assignment.value]
                                                      [assignment.key],
                                                ),
                                              ),
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
