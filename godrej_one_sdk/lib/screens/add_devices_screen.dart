import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/widgets/coming_soon_body.dart';

/// Placeholder body for the "Add Devices" tab.
class AddDevicesScreen extends StatelessWidget {
  const AddDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonBody(
      title: 'Add Devices',
      icon: Icons.workspaces_filled,
      message: 'Pair a new device to your home in a few taps.',
    );
  }
}
