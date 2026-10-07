import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/models/space.dart';
import 'package:godrej_one_sdk/screens/property_screen.dart';
import 'package:godrej_one_sdk/screens/space_detail_screen.dart';
import 'package:godrej_one_sdk/service/show_elegant_toast.dart';
import 'package:godrej_one_sdk/widgets/glassy_container.dart';
import 'package:godrej_one_sdk/widgets/greeting_header.dart';
import 'package:godrej_one_sdk/widgets/home_camera_widgets.dart';
import 'package:godrej_one_sdk/widgets/my_spaces_card.dart';
import 'package:godrej_one_sdk/widgets/tab_navigator.dart';

/// The "My Spaces" tab: a grid of the home's rooms; tapping one opens its
/// [SpaceDetailScreen] inside the tab.
class MySpacesScreen extends StatelessWidget {
  const MySpacesScreen({super.key, required this.name, required this.asset});

  final String name, asset;

  @override
  Widget build(BuildContext context) {
    return TabNavigator(
      tabId: 'my_space',
      root: _SpacesGridPage(name: name, asset: asset),
    );
  }
}

class _SpacesGridPage extends StatelessWidget {
  const _SpacesGridPage({required this.name, required this.asset});

  final String name, asset;

  void _openSpace(BuildContext context, Space space) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SpaceDetailScreen(space: space, name: name, asset: asset),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;

    // Clearance formula for bottom bottom navigation bar chrome
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed Top Navigation Header
        GreetingHeader(
          name: name,
          asset: asset,
          subtitle: 'Mumbai Home',
          trailing: HomeCameraWidgets(
            status: 1,
            onHomeTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PropertyScreen()),
            ),
          ),
        ),

        // Scrollable Body Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 8.0,
              bottom: barHeight + media.padding.bottom + gap * 2,
            ),
            child: Column(
              children: [
                // Two tiles per row; an odd last tile keeps its half width.
                for (var i = 0; i < demoSpaces.length; i += 2) ...[
                  Row(
                    children: [
                      _tile(context, demoSpaces[i]),
                      const SizedBox(width: 16),
                      if (i + 1 < demoSpaces.length)
                        _tile(context, demoSpaces[i + 1])
                      else
                        const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
                Row(
                  children: [
                    GlassyContainer(
                      flex: 1,
                      height: 150,
                      title: 'Add Space',
                      imageExists: true,
                      imagePath: 'images/spaces/Vector.png',
                      imageAlignment: Alignment.bottomLeft,
                      imageWidthFactor: 0.26,
                      imageHeightFactor: 0.26,
                      imagePadding: const EdgeInsets.fromLTRB(18, 0, 0, 16),
                      onTap: () =>
                          showElegantToast(context, 'More spaces coming soon'),
                    ),
                    const SizedBox(width: 16),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tile(BuildContext context, Space space) {
    return MySpacesCard(
      img_path: space.image,
      label: space.label,
      id: space.id,
      handleClick: () => _openSpace(context, space),
    );
  }
}
