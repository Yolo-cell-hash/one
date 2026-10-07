import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:godrej_one_sdk/platform/adaptive.dart';
import 'package:godrej_one_sdk/widgets/search_bar_widget.dart';
import 'package:godrej_one_sdk/widgets/customization_card.dart';
import 'package:godrej_one_sdk/widgets/elevated_container.dart';

/// Placeholder body for the "Customize" tab.
class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  static const _brand = Color(0xFF810055);
  final headerHeight = 85.0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    // Same formula HomeShell uses for its own bar, so this always clears it
    // exactly — the bar is fixed chrome owned by HomeShell, this screen only
    // needs to leave room for it.
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed Top Navigation Header
        Padding(
          padding: const EdgeInsets.only(
            top: 85,
            left: 30,
            right: 30,
            bottom: 25.0,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Navigation',
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
                      color: secondaryControlFill(context),
                      borderRadius: BorderRadius.circular(22.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        adaptiveIcon(context, Icons.more_vert_rounded),
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

        // Scrollable Body Content
        Expanded(
          child: SingleChildScrollView(
            // iOS lists put the keyboard away when you start scrolling them.
            keyboardDismissBehavior: isCupertino(context)
                ? ScrollViewKeyboardDismissBehavior.onDrag
                : ScrollViewKeyboardDismissBehavior.manual,
            padding: EdgeInsets.only(
              bottom: barHeight + media.padding.bottom + gap * 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SearchBarWidget(labelText: 'Search Customization'),
                const SizedBox(height: 25.0),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: SelectableText(
                    "Dynamic Navigation Bar",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _brand,
                      fontFamily: "GEG",
                      package: "godrej_one_sdk",
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),
                ElevatedContainer(toggleNeeded: false),
                const SizedBox(height: 25.0),
                const CustomizationCard(
                  id: 'activity_trails',
                  title: 'Audit Trail',
                  subtitle: 'Activity History',
                  card_icon: Icons.access_time_filled,
                  hasIcon: true,
                ),
                const CustomizationCard(
                  id: 'devices',
                  title: 'Devices',
                  subtitle: 'Connected Control',
                  card_icon: Icons.workspaces_filled,
                  hasIcon: true,
                ),
                const CustomizationCard(
                  id: 'widgets',
                  title: 'Widgets',
                  subtitle: 'Smart Information',
                  card_icon: Icons.widgets,
                  hasIcon: true,
                ),
                const CustomizationCard(
                  id: 'my_space',
                  title: 'My Space',
                  subtitle: 'Home Overview',
                  hasIcon: false,
                  cardImage: 'images/svgs/spaces.svg',
                  cardImagePackage: 'godrej_one_sdk',
                ),
                const CustomizationCard(
                  id: 'modes',
                  title: 'Modes',
                  subtitle: 'Scenes Presets',
                  hasIcon: false,
                  cardImage: 'images/svgs/modes.svg',
                  cardImagePackage: 'godrej_one_sdk',
                ),
                const CustomizationCard(
                  id: 'habits',
                  title: 'Habits',
                  subtitle: 'Smart Routines',
                  hasIcon: false,
                  cardImage: 'images/svgs/habits.svg',
                  cardImagePackage: 'godrej_one_sdk',
                ),
                const CustomizationCard(
                  id: 'device_detection',
                  title: 'Device Detection',
                  subtitle: 'Scan to find / Auto Detect',
                  hasIcon: false,
                  cardImage: 'images/svgs/device_detection.svg',
                  cardImagePackage: 'godrej_one_sdk',
                ),
                const SizedBox(height: 25.0),
                ElevatedContainer(toggleNeeded: true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
