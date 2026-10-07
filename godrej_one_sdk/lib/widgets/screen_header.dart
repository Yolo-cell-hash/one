import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/platform/adaptive.dart';

/// Centered brand-colored page title with the round "more" button pinned to
/// the right — the top of the plain white tabs (Activity Trail and its
/// device detail page).
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title});

  final String title;

  static const _brand = Color(0xFF810055);

  @override
  Widget build(BuildContext context) {
    return AdaptiveStatusBar(lightContent: false, child: _buildHeader(context));
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      // Fixed top inset, same as the Customize tab's header, so titles sit
      // at the same height when switching tabs. Only 8px at the sides so the
      // iOS back chevron can sit near the screen edge; the "more" button adds
      // the rest of the 30px gutter itself.
      padding: const EdgeInsets.only(top: 85, left: 8, right: 8),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Positioned, so its 44pt tap target doesn't make the header
            // taller (and shift the title) on pushed pages.
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(child: AdaptiveBackButton(color: _brand)),
            ),
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
              child: Padding(
                padding: const EdgeInsets.only(right: 22),
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      adaptiveIcon(context, Icons.more_vert_rounded),
                      size: 22,
                      color: _brand,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
