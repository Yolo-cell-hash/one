import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key, required this.labelText});

  final String labelText;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {

  static const _brand = Color(0xFF810055);

  @override
  Widget build(BuildContext context) {
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
}
