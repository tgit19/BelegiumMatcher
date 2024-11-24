import 'package:flutter/material.dart';

class AssignmentWidget extends StatelessWidget {
  /// name of the wg
  final String wg;

  /// name of the person
  final String person;

  /// score of the wg
  final int wgScore;

  /// score of the person
  final int personScore;

  const AssignmentWidget({
    super.key,
    required this.wg,
    required this.person,
    required this.wgScore,
    required this.personScore,
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
              Text(person),
            ],
          ),
          SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$personScore/$wgScore",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Icon(Icons.compare_arrows),
            ],
          ),
          SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(wg),
            ],
          ),
        ],
      );
}
