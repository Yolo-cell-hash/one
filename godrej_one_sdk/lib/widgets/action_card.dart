import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/platform/adaptive.dart';

const _brand = Color(0xFF810055);

/// Solid brand-colored pill button — "Create", "Add", "Scan QR".
class BrandPillButton extends StatelessWidget {
  const BrandPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.fontSize = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
  });

  final String label;
  final VoidCallback onTap;
  final double fontSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white,
        fontFamily: 'GEG',
        package: 'godrej_one_sdk',
      ),
    );

    // iOS buttons dim while pressed instead of drawing an ink highlight.
    if (isCupertino(context)) {
      return CupertinoButton(
        onPressed: onTap,
        padding: padding,
        minimumSize: Size.zero,
        color: _brand,
        borderRadius: BorderRadius.circular(999),
        child: text,
      );
    }

    return Material(
      color: _brand,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: text),
      ),
    );
  }
}

/// Soft raised card with a brand title and one pill button under it —
/// "Create new property · Create", "Godrej Device · Add".
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: _brand,
              fontFamily: 'GEG',
              package: 'godrej_one_sdk',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          BrandPillButton(label: buttonLabel, onTap: onPressed),
        ],
      ),
    );
  }
}
