import 'package:flutter/material.dart';

/// Centered brand-colored page title with the round "more" button pinned to
/// the right — the top of the plain white tabs (Activity Trail and its
/// device detail page).
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title});

  final String title;

  static const _brand = Color(0xFF810055);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Fixed top inset, same as the Customize tab's header, so titles sit
      // at the same height when switching tabs.
      padding: const EdgeInsets.only(top: 85, left: 30, right: 30),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                color: _brand,
                fontFamily: 'GEG',
                package: 'godrej_one_sdk',
                fontWeight: FontWeight.w500,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E6E6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.more_vert_rounded, size: 22, color: _brand),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
