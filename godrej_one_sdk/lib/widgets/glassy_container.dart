import 'dart:ui';

import 'package:flutter/material.dart';

const _brand = Color(0xFF810055);
const _defaultBorder = Color(0xFF8DFC63);
const _radius = 25.0;

const _titleStyle = TextStyle(
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: _brand,
);

const _subtitleStyle = TextStyle(
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: _brand,
);

class GlassyContainer extends StatelessWidget {
  const GlassyContainer({
    super.key,
    this.height,
    this.width,
    this.flex,
    required this.title,
    this.subtitle,
    this.borderExists = false,
    this.borderColor = _defaultBorder,
    this.imageExists = false,
    this.imagePath,
  });

  final double? height;
  final double? width;

  /// When set, the card sizes itself off its parent Row or Column instead of
  /// [width], so a row can mix wide and narrow cards.
  final int? flex;

  final String title;
  final String? subtitle;
  final bool borderExists;
  final Color borderColor;
  final bool imageExists;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    const shape = BorderRadius.all(Radius.circular(_radius));
    final image = imagePath;

    final card = SizedBox(
      height: height,
      width: flex == null ? width : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: shape,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: shape,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: shape,
                border: Border.all(
                  color: borderExists
                      ? borderColor
                      : Colors.white.withValues(alpha: 0.65),
                ),
              ),
              child: Stack(
                children: [
                  if (imageExists && image != null)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FractionallySizedBox(
                          widthFactor: 0.72,
                          heightFactor: 0.62,
                          child: Image.asset(
                            image,
                            package: 'godrej_one_sdk',
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: _titleStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            subtitle!,
                            style: _subtitleStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return flex == null ? card : Expanded(flex: flex!, child: card);
  }
}
