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

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;

    // Same metrics as HomeShell, to keep the last row clear of the floating bar.
    final gap = (w * 0.035).clamp(12.0, 18.0);
    final barHeight = (w * 0.19).clamp(66.0, 84.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 85, left: 30, right: 30),
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
                        AppIcons.more.of(context),
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
        SearchBarWidget(labelText: 'Search Customization'),
        SizedBox(height: 25.0),
        // The title and search stay pinned; the list scrolls beneath them.
        // It used to be a plain Column that ran off the bottom of the screen
        // (and under the floating bar) on shorter phones.
        Expanded(
          child: SingleChildScrollView(
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
                SizedBox(height: 25.0),
                ElevatedContainer(),
                SizedBox(height: 25.0),
                CustomizationCard(
                  title: 'Audit Trail',
                  subtitle: 'Activity History',
                  card_icon: AppIcons.activity.of(context),
                  hasIcon: true,
                ),
                CustomizationCard(
                  title: 'Devices',
                  subtitle: 'Connected Control',
                  card_icon: AppIcons.devices.of(context),
                  hasIcon: true,
                ),
                CustomizationCard(
                  title: 'Widgets',
                  subtitle: 'Smart Information',
                  card_icon: AppIcons.widgets.of(context),
                  hasIcon: true,
                ),
                CustomizationCard(
                  title: 'My Space',
                  subtitle: 'Home Overview',
                  hasIcon: false,
                  cardImage: 'images/svgs/spaces.svg',
                  cardImagePackage: 'godrej_one_sdk',
                ),
                CustomizationCard(
                  title: 'Modes',
                  subtitle: 'Scenes Presets',
                  hasIcon: false,
                  cardImage: 'images/svgs/modes.svg',
                  cardImagePackage: 'godrej_one_sdk',
                ),
                CustomizationCard(
                  title: 'Habits',
                  subtitle: 'Smart Routines',
                  hasIcon: false,
                  cardImage: 'images/svgs/habits.svg',
                  cardImagePackage: 'godrej_one_sdk',
                ),
                CustomizationCard(
                  title: 'Device Detection',
                  subtitle: 'Scan to find / Auto Detect',
                  hasIcon: false,
                  cardImage: 'images/svgs/device_detection.svg',
                  cardImagePackage: 'godrej_one_sdk',
                )

              ],
            ),
          ),
        ),
      ],
    );
  }
}
