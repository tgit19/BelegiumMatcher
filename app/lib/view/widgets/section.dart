import 'package:flutter/material.dart';

class SectionWidget extends StatelessWidget {
  /// title to display
  final String title;

  /// optional status icon of the title
  final Widget? titleStaus;

  /// content of the section
  final Widget? child;

  const SectionWidget({
    super.key,
    required this.title,
    this.titleStaus,
    this.child,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          ListTile(
            title: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            trailing: titleStaus,
          ),
          if (child != null)
            ListTile(
              title: child!,
            ),
        ],
      );
}
