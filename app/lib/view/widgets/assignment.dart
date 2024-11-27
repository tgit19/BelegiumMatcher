import 'package:flutter/material.dart';

class AssignmentWidget extends StatelessWidget {
  /// name of the person
  final String a;

  /// name of the wg
  final String b;

  /// score of the person
  final int aScore;

  /// score of the wg
  final int bScore;

  const AssignmentWidget({
    super.key,
    required this.b,
    required this.a,
    required this.aScore,
    required this.bScore,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(a),
            ],
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$aScore/$bScore",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Icon(Icons.compare_arrows),
            ],
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(b),
            ],
          ),
        ],
      );
}
