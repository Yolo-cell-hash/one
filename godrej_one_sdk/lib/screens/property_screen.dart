import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/service/show_elegant_toast.dart';
import 'package:godrej_one_sdk/widgets/action_card.dart';
import 'package:godrej_one_sdk/widgets/screen_header.dart';
import 'package:godrej_one_sdk/widgets/search_bar_widget.dart';

/// "Property" page, opened from the home button in the Home / My Spaces
/// headers: start a new property, with a note on why one is needed.
class PropertyScreen extends StatelessWidget {
  const PropertyScreen({super.key});

  static const _brand = Color(0xFF810055);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    // Same formulas HomeShell uses for its bar, so the note always sits
    // just above it.
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          const ScreenHeader(title: 'Property'),
          const SizedBox(height: 25.0),
          const SearchBarWidget(labelText: 'Search Properties'),
          const SizedBox(height: 30.0),
          ActionCard(
            title: 'Create new property',
            buttonLabel: 'Create',
            onPressed: () =>
                showElegantToast(context, 'Property creation coming soon'),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'Create a property to add a device and assign the property to '
              'the device for secure access control.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: _brand,
                fontFamily: 'GEG',
                package: 'godrej_one_sdk',
              ),
            ),
          ),
          SizedBox(height: barHeight + media.padding.bottom + gap * 2.5),
        ],
      ),
    );
  }
}
