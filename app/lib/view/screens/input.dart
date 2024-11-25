import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';

import '../../services/input.dart';

class InputScreen extends StatefulWidget {
  final InputFileService fileService;

  const InputScreen({
    super.key,
    required this.fileService,
  });

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // number of rooms per wg
  final Map<int, int> wgRoomCounts = {};

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ListenableBuilder(
            listenable: widget.fileService,
            builder: (context, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.fileService.file != null &&
                    widget.fileService.error == null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "wg room counts",
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              Wrap(
                                children: [
                                  for (int i = 0;
                                      i <
                                          widget.fileService.file!.wgs
                                              .toSet()
                                              .length;
                                      i++)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InputQty.int(
                                        initVal: 1,
                                        minVal: 1,
                                        decoration: QtyDecorationProps(
                                          leadingWidget: Text(
                                            widget.fileService.file!.wgs[i],
                                          ),
                                          qtyStyle: QtyStyle.btnOnRight,
                                        ),
                                        onQtyChanged: (value) => setState(
                                            () => wgRoomCounts[i] = value),
                                      ),
                                    ),
                                ],
                              ),
                            ],
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
                        onPressed: widget.fileService.loading
                            ? null
                            : () => widget.fileService.selectFile().then(
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
                    if (widget.fileService.error == null &&
                        widget.fileService.personMatrix != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 8.0,
                        ),
                        child: ElevatedButton(
                          onPressed: widget.fileService.matching
                              ? null
                              : () =>
                                  widget.fileService.match(wgRoomCounts).then(
                                    (value) {
                                      Navigator.maybeOf(context)
                                          ?.pushNamed("/results")
                                          .then(
                                            (_) => widget.fileService.reload(),
                                          );
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
