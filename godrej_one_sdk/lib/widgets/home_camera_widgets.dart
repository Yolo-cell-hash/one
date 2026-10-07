import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/platform/adaptive.dart';

class HomeCameraWidgets extends StatefulWidget {
  const HomeCameraWidgets({super.key, required this.status});

  final int status;

  @override
  State<HomeCameraWidgets> createState() => _HomeCameraWidgetsState();
}

class _HomeCameraWidgetsState extends State<HomeCameraWidgets> {
  @override
  Widget build(BuildContext context) {
    if (widget.status == 0) {
      return Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              'images/home_landing_icon.png',
              package: 'godrej_one_sdk',
              width: 34,
              height: 34,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              'images/camera_landing_icon.png',
              package: 'godrej_one_sdk',
              width: 34,
              height: 34,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              'images/home_landing_icon.png',
              package: 'godrej_one_sdk',
              width: 34,
              height: 34,
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () {},
            // The asset is Android's vertical overflow dots on a round disc;
            // a quarter turn gives iOS its horizontal ellipsis.
            child: RotatedBox(
              quarterTurns: isCupertino(context) ? 1 : 0,
              child: Image.asset(
                'images/chevron.png',
                package: 'godrej_one_sdk',
                width: 34,
                height: 34,
              ),
            ),
          ),
        ],
      );
    }
  }
}
