import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/service/show_elegant_toast.dart';
import 'package:godrej_one_sdk/widgets/action_card.dart';
import 'package:godrej_one_sdk/widgets/device_catalog_page.dart';
import 'package:godrej_one_sdk/widgets/screen_header.dart';
import 'package:godrej_one_sdk/widgets/search_bar_widget.dart';
import 'package:godrej_one_sdk/widgets/tab_navigator.dart';

/// The "Add Devices" tab: pick a device brand to pair, or scan for one.
/// "Add" on Godrej Device opens the Godrej Devices list inside the tab.
class AddDevicesScreen extends StatelessWidget {
  const AddDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabNavigator(tabId: 'devices', root: _AddDevicePage());
  }
}

class _AddDevicePage extends StatelessWidget {
  const _AddDevicePage();

  void _openGodrejDevices(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DeviceCatalogPage(
          title: 'Godrej Devices',
          onDeviceTap: (context, device) =>
              showElegantToast(context, 'Pairing ${device.name} coming soon'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    // Same formulas HomeShell uses for its bar, so the scan buttons always
    // sit just above it.
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          const ScreenHeader(title: 'Add device'),
          const SizedBox(height: 25.0),
          const SearchBarWidget(labelText: 'Search Devices'),
          const SizedBox(height: 30.0),
          ActionCard(
            title: 'Godrej Device',
            buttonLabel: 'Add',
            onPressed: () => _openGodrejDevices(context),
          ),
          const Spacer(),
          BrandPillButton(
            label: 'Scan QR',
            onTap: () => showElegantToast(context, 'QR scanning coming soon'),
          ),
          const SizedBox(height: 14),
          BrandPillButton(
            label: 'Scan Nearby',
            onTap: () =>
                showElegantToast(context, 'Nearby scanning coming soon'),
          ),
          SizedBox(height: barHeight + media.padding.bottom + gap * 2.5),
        ],
      ),
    );
  }
}
