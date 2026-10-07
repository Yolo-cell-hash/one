import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:godrej_one_sdk/platform/adaptive.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key, required this.labelText});

  final String labelText;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {

  static const _brand = Color(0xFF810055);

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isCupertino(context)) return _buildCupertino();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Material(
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        child: TextField(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: _brand),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  /// The system search field. iOS has no back button to put the keyboard
  /// away, so a tap anywhere outside the field (or its text-selection
  /// toolbar, which shares the text field's tap region) dismisses it.
  Widget _buildCupertino() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextFieldTapRegion(
        onTapOutside: (_) => _focusNode.unfocus(),
        child: CupertinoSearchTextField(
          focusNode: _focusNode,
          placeholder: widget.labelText,
          onSubmitted: (_) => _focusNode.unfocus(),
        ),
      ),
    );
  }
}
