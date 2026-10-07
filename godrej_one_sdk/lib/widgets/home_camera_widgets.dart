import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/platform/adaptive.dart';

class HomeCameraWidgets extends StatefulWidget {
  const HomeCameraWidgets({super.key, required this.status, this.onHomeTap});

  final int status;

  /// Tap on the home (property) button — e.g. open the Property page.
  final VoidCallback? onHomeTap;

  @override
  State<HomeCameraWidgets> createState() => _HomeCameraWidgetsState();
}

class _HomeCameraWidgetsState extends State<HomeCameraWidgets> {
  @override
  Widget build(BuildContext context) {
    if (widget.status == 0) {
      return Column(
        children: [
          GestureDetector(onTap: widget.onHomeTap, child: const _HomeButton()),
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
          GestureDetector(onTap: widget.onHomeTap, child: const _HomeButton()),
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

/// Round light-grey button with the brand house-and-dot glyph, sized to sit
/// beside the other 34px header buttons.
class _HomeButton extends StatelessWidget {
  const _HomeButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFE4E4E2),
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        'images/home_property_icon.png',
        package: 'godrej_one_sdk',
        height: 17,
        fit: BoxFit.contain,
      ),
    );
  }
}
