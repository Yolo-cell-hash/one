import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/widgets/search_bar_widget.dart';

/// Placeholder body for the "Activity Trails" tab.
class ActivityTrailsScreen extends StatelessWidget {
  const ActivityTrailsScreen({super.key});

  static const _brand = Color(0xFF810055);

  @override
  Widget build(BuildContext context) {
    // ComingSoonBody already fills the available space and centers its own
    // card — wrapping it in another Column gives it unbounded height (a
    // plain Column doesn't constrain its children), which breaks its
    // internal Expanded. Return it directly.
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 85, left: 30, right: 30),
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Activity Trail',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: _brand,
                    fontFamily: 'GEG',
                    package: 'godrej_one_sdk',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(22.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 22,
                        color: _brand,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 25.0),
        SearchBarWidget( labelText: 'Search Devices',),
      ],
    );
  }
}
