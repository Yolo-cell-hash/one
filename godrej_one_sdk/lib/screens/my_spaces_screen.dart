import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/widgets/coming_soon_body.dart';

/// Placeholder body for the "My Spaces" tab.
class MySpacesScreen extends StatelessWidget {
  const MySpacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonBody(
      title: 'My Spaces',
      icon: Icons.space_dashboard_outlined,
      message: 'Group your devices by room, floor or however you like.',
    );
  }
}
