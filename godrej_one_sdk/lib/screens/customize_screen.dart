import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/widgets/customization_card.dart';
import 'package:godrej_one_sdk/widgets/elevated_container.dart';
import 'package:godrej_one_sdk/widgets/screen_header.dart';
import 'package:godrej_one_sdk/widgets/search_bar_widget.dart';

/// The "Navigation" page, opened by long-pressing the bar's last slot:
/// choose which features the dynamic navigation bar shows.
class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  static const _brand = Color(0xFF810055);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    // Same formula HomeShell uses for its own bar, so this always clears it
    // exactly — the bar is fixed chrome owned by HomeShell, this screen only
    // needs to leave room for it.
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);

    return Material(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(title: 'Navigation'),
          const SizedBox(height: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 6,
                bottom: barHeight + media.padding.bottom + gap * 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SearchBarWidget(labelText: 'Search Devices'),
                  const SizedBox(height: 26),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 31),
                    child: Text(
                      'Dynamic navigation bar',
                      style: TextStyle(
                        fontSize: 16.5,
                        color: _brand,
                        fontFamily: 'GEG',
                        package: 'godrej_one_sdk',
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const ElevatedContainer(toggleNeeded: false),
                  const SizedBox(height: 24),
                  const CustomizationCard(
                    id: 'activity_trails',
                    title: 'Audit trail',
                    subtitle: 'Activity History',
                    icon: Icons.access_time_filled,
                  ),
                  const CustomizationCard(
                    id: 'devices',
                    title: 'Devices',
                    subtitle: 'Connected Control',
                    icon: Icons.workspaces_filled,
                  ),
                  const CustomizationCard(
                    id: 'my_space',
                    title: 'My Space',
                    subtitle: 'Home Overview',
                    cardImage: 'images/svgs/spaces.svg',
                  ),
                  const CustomizationCard(
                    id: 'device_detection',
                    title: 'Device detection',
                    subtitle: 'Scan to find / Auto detect',
                    cardImage: 'images/svgs/device_detection.svg',
                  ),
                  const CustomizationCard(
                    id: 'widgets',
                    title: 'Widgets',
                    subtitle: 'Smart Information',
                    icon: Icons.dashboard_customize_rounded,
                  ),
                  const CustomizationCard(
                    id: 'habits',
                    title: 'Habits',
                    subtitle: 'Smart Routines',
                    cardImage: 'images/svgs/habits.svg',
                  ),
                  const CustomizationCard(
                    id: 'modes',
                    title: 'Modes',
                    subtitle: 'Scene Presets',
                    cardImage: 'images/svgs/modes.svg',
                  ),
                  const SizedBox(height: 90),
                  const ElevatedContainer(toggleNeeded: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
