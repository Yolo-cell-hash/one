import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/widgets/glassy_container.dart';

const _brand = Color(0xFF810055);

/// Shared body for a tab that doesn't have real content yet: a pinned title
/// matching the Home tab's header rhythm, and a centered glassy card so the
/// tab reads as intentional rather than empty.
class ComingSoonBody extends StatelessWidget {
  const ComingSoonBody({
    super.key,
    required this.title,
    required this.icon,
    this.message = 'This is on its way. Check back soon.',
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;

    final gutter = (w * 0.045).clamp(14.0, 24.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);
    final barHeight = (w * 0.19).clamp(66.0, 84.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        gutter,
        media.padding.top + 16,
        gutter,
        barHeight + media.padding.bottom + gap * 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: (w * 0.055).clamp(18.0, 24.0),
              fontFamily: 'GEG',
              package: 'godrej_one_sdk',
              fontWeight: FontWeight.w400,
              height: 1.15,
              color: Colors.white,
            ),
          ),
          SizedBox(height: gap * 1.6),
          Expanded(
            child: Center(
              child: GlassyContainer(
                width: double.infinity,
                height: (w * 0.6).clamp(220.0, 320.0),
                padding: EdgeInsets.all(gap * 1.4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: (w * 0.14).clamp(40.0, 56.0),
                      color: _brand,
                    ),
                    SizedBox(height: gap),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (w * 0.037).clamp(13.0, 16.0),
                        fontFamily: 'GEG',
                        package: 'godrej_one_sdk',
                        fontWeight: FontWeight.w400,
                        color: _brand,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
