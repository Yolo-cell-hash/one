import 'package:flutter/material.dart';

/// Soft grey pill search field with a brand magnifier — the search at the
/// top of the device, property and navigation pages.
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key, required this.labelText, this.onChanged});

  /// Placeholder shown while the field is empty.
  final String labelText;
  final ValueChanged<String>? onChanged;

  static const _brand = Color(0xFF810055);
  static const _text = TextStyle(
    fontSize: 16,
    fontFamily: 'GEG',
    package: 'godrej_one_sdk',
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          cursorColor: _brand,
          style: _text.copyWith(color: Colors.black),
          decoration: InputDecoration(
            hintText: labelText,
            hintStyle: _text.copyWith(color: const Color(0xFFB0B0B0)),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: _brand, size: 26),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 54,
              minHeight: 46,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    );
  }
}
