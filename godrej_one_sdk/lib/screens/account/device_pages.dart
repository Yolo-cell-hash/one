import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/models/trail_device.dart';
import 'package:godrej_one_sdk/providers/bottom_bar_provider.dart';
import 'package:godrej_one_sdk/screens/device_activity_screen.dart';
import 'package:godrej_one_sdk/widgets/action_card.dart';
import 'package:godrej_one_sdk/widgets/device_catalog_page.dart';

void _openActivity(BuildContext context, TrailDevice device) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DeviceActivityScreen(device: device),
      ),
    );

/// Every device on the account. Tapping one opens its activity trail;
/// Add Device goes to the Add Devices tab.
class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DeviceCatalogPage(
      title: 'Devices',
      onDeviceTap: _openActivity,
      footer: BrandPillButton(
        label: 'Add Device',
        fontSize: 18,
        onTap: () => context.read<BottomBarProvider>().selectById('devices'),
      ),
    );
  }
}

/// The account's locks. Tapping one opens its activity trail.
class ManageLocksScreen extends StatelessWidget {
  const ManageLocksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DeviceCatalogPage(
      title: 'Manage locks',
      onDeviceTap: _openActivity,
      only: DeviceCategory.locks,
    );
  }
}
