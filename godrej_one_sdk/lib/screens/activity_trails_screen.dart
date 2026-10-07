import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/screens/device_activity_screen.dart';
import 'package:godrej_one_sdk/widgets/device_catalog_page.dart';
import 'package:godrej_one_sdk/widgets/tab_navigator.dart';

/// The "Activity Trails" tab: a searchable, filterable list of devices;
/// tapping one opens its [DeviceActivityScreen] inside the tab.
class ActivityTrailsScreen extends StatelessWidget {
  const ActivityTrailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabNavigator(
      tabId: 'activity_trails',
      root: DeviceCatalogPage(
        title: 'Activity Trail',
        onDeviceTap: (context, device) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DeviceActivityScreen(device: device),
          ),
        ),
      ),
    );
  }
}
