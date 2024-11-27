import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';

import '../../constants.dart';
import '../../model/table_position.dart';
import '../../services/match.dart';
import '../widgets/assignment.dart';
import '../widgets/matrix.dart';
import '../widgets/section.dart';
import '../widgets/table.dart';

class FlowScreen extends StatefulWidget {
  /// service to perform matches
  final MatchService service;

  /// flag to show / hide matrices
  final bool showMatrices;

  const FlowScreen({
    super.key,
    required this.service,
    this.showMatrices = false,
  });

  @override
  State<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends State<FlowScreen> {
  /// key of item to scroll to on service changes
  final scrollKey = GlobalKey();

  void scrollToWidget(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final context = key.currentContext;
        if (context == null) return;

        Scrollable.ensureVisible(
          context,
          duration: kScrollDuration,
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void initState() {
    widget.service.addListener(listener);
    super.initState();
  }

  void listener() {
    setState(() {});
    scrollToWidget(scrollKey);
  }

  @override
  void dispose() {
    widget.service.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SectionWidget(
                title: "1) select file",
                titleStaus: widget.service.activeStep == 0
                    ? Icon(Icons.file_open_outlined)
                    : 0 < widget.service.activeStep
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
                            onPressed: widget.service.running
                                ? null
                                : () => widget.service.run(0),
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
                        if (widget.service.file != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 8.0,
                            ),
                            child: ElevatedButton(
                              onPressed: widget.service.running
                                  ? null
                                  : () => widget.service.run(1),
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
              if (widget.service.activeStep >= 1)
                SectionWidget(
                  title: "2) load file content",
                  titleStaus: widget.service.file?.error != null
                      ? Icon(Icons.error_outline)
                      : 1 < widget.service.activeStep
                          ? Icon(Icons.done)
                          : CircularProgressIndicator(),
                  child: !widget.service.fastForward ||
                          widget.service.file!.error != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.service.file!.error != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TableWidget(
                                  table: widget.service.file!.table,
                                  highlightPosition: widget.service.file!.error
                                          ?.source is TablePosition
                                      ? widget.service.file!.error?.source
                                      : null,
                                ),
                              ),
                            if (widget.service.file!.error == null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TableWidget(
                                  table: widget.service.file!.tables[0],
                                ),
                              ),
                            if (widget.service.file!.error == null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TableWidget(
                                  table: widget.service.file!.tables[1],
                                ),
                              ),
                            if (widget.service.file!.error != null)
                              Text(
                                widget.service.file!.error.toString(),
                              ),
                          ],
                        )
                      : null,
                ),
              if (widget.service.activeStep >= 2 && !widget.service.fastForward)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SectionWidget(
                      title: "3.a) duplicate A columns",
                      titleStaus: 2 < widget.service.activeStep
                          ? Icon(Icons.done)
                          : Icon(Icons.edit),
                      child: Wrap(
                        children: [
                          for (int i = 0;
                              i < widget.service.file!.wgs.toSet().length;
                              i++)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InputQty.int(
                                initVal: widget.service.matrixRowHeaderMapA[i]!,
                                minVal: 1,
                                decoration: QtyDecorationProps(
                                  leadingWidget: Text(
                                    widget.service.file!.wgs[i],
                                  ),
                                  qtyStyle: QtyStyle.btnOnRight,
                                ),
                                onQtyChanged: (value) => widget
                                    .service.matrixRowHeaderMapA[i] = value,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SectionWidget(
                      title: "3.b) duplicate B columns",
                      titleStaus: 2 < widget.service.activeStep
                          ? Icon(Icons.done)
                          : Icon(Icons.edit),
                      child: Wrap(
                        children: [
                          for (int i = 0;
                              i < widget.service.file!.persons.toSet().length;
                              i++)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InputQty.int(
                                initVal: widget.service.matrixRowHeaderMapB[i]!,
                                minVal: 1,
                                decoration: QtyDecorationProps(
                                  leadingWidget: Text(
                                    widget.service.file!.persons[i],
                                  ),
                                  qtyStyle: QtyStyle.btnOnRight,
                                ),
                                onQtyChanged: (value) => widget
                                    .service.matrixRowHeaderMapB[i] = value,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.service.activeStep == 2)
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
                              onPressed: widget.service.running
                                  ? null
                                  : widget.service.run,
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
              if (widget.service.activeStep >= 3)
                SectionWidget(
                  title: "4) transform data",
                  titleStaus: 3 < widget.service.activeStep
                      ? Icon(Icons.done)
                      : CircularProgressIndicator(),
                  child: widget.showMatrices
                      ? Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const SizedBox(
                              width: 16.0,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("A = "),
                                MatrixWidget(widget.service.matrixA!),
                              ],
                            ),
                            Text(','),
                            SizedBox(width: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("B = "),
                                MatrixWidget(widget.service.matrixB!),
                              ],
                            ),
                          ],
                        )
                      : null,
                ),
              SizedBox(
                key: scrollKey,
              ),
              if (widget.service.activeStep >= 4)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // loop through strategies
                    for (int i = 0;
                        i <
                            widget
                                .service.combinationFunctionDescriptions.length;
                        i++)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SectionWidget(
                            title:
                                "5.${i + 1}) ${widget.service.combinationFunctionDescriptions.elementAt(i)}",
                            titleStaus: Text(
                              widget.service.solutions
                                  .elementAt(i)
                                  .costs
                                  .toString(),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 16.0,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.showMatrices)
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("M = "),
                                              MatrixWidget(
                                                widget.service.problems[i].key,
                                                highlightPoints: widget
                                                        .service.solutions
                                                        .elementAtOrNull(i)
                                                        ?.assignments ??
                                                    const [],
                                              ),
                                              Center(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16.0,
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text("max"),
                                                          Icon(
                                                              Icons.swap_horiz),
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
                                                widget
                                                    .service.problems[i].value,
                                                highlightPoints: widget
                                                        .service.solutions
                                                        .elementAtOrNull(i)
                                                        ?.assignments ??
                                                    const [],
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (widget.showMatrices)
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                      Wrap(
                                        children: [
                                          for (MapEntry<int, int> assignment
                                              in widget.service.solutions[i]
                                                  .assignments)
                                            if (assignment.key <
                                                    widget
                                                        .service
                                                        .matrixRowHeaderB
                                                        .length &&
                                                assignment.value <
                                                    widget
                                                        .service
                                                        .matrixRowHeaderA
                                                        .length)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: widget.service
                                                                          .matrixA![
                                                                      assignment
                                                                          .key][
                                                                  assignment
                                                                      .value] <
                                                              0
                                                          ? Colors.red
                                                          : Colors.black,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  padding: EdgeInsets.all(8.0),
                                                  child: AssignmentWidget(
                                                    a: widget.service
                                                            .matrixRowHeaderB[
                                                        assignment.key],
                                                    b: widget.service
                                                            .matrixRowHeaderA[
                                                        assignment.value],
                                                    aScore:
                                                        widget.service.matrixA![
                                                                assignment.key]
                                                            [assignment.value],
                                                    bScore:
                                                        widget.service.matrixB![
                                                                assignment
                                                                    .value]
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
