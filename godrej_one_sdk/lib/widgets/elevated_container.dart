import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/platform/adaptive.dart';

class ElevatedContainer extends StatefulWidget {
  const ElevatedContainer({super.key});

  @override
  State<ElevatedContainer> createState() => _ElevatedContainerState();
}

class _ElevatedContainerState extends State<ElevatedContainer> {
  static const _brand = Color(0xFF810055);

  @override
  Widget build(BuildContext context) {
    // iOS draws grouped content as a flat, filled panel; Material lifts it
    // with an elevation shadow.
    final cupertino = isCupertino(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Material(
        elevation: cupertino ? 0 : 5,
        color: cupertino
            ? CupertinoColors.secondarySystemBackground.resolveFrom(context)
            : Colors.white,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How does it work? ',
                style: const TextStyle(
                  fontSize: 16,
                  color: _brand,
                  fontFamily: "GEG",
                  package: 'godrej_one_sdk',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SelectableText(
                'Add upto 3 icons to your dynamic navigation toolbar & create a personalised shortcut menu for quick, easy access to your favorite features. ',
                style: const TextStyle(
                  fontSize: 16,
                  color: _brand,
                  fontFamily: "GEG",
                  package: 'godrej_one_sdk',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
