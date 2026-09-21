import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/screens/activity_trails_screen.dart';
import 'package:godrej_one_sdk/screens/add_devices_screen.dart';
import 'package:godrej_one_sdk/screens/customize_screen.dart';
import 'package:godrej_one_sdk/screens/home_screen.dart';
import 'package:godrej_one_sdk/screens/my_spaces_screen.dart';
import 'package:godrej_one_sdk/widgets/glassy_container.dart';

/// Persistent chrome for the bottom-tab flow: the background image and the
/// floating bottom bar are built once, here, and stay in place while
/// [IndexedStack] swaps which tab's body is visible.
///
/// Tapping a bar icon just updates [_index] — no [Navigator] involved — so
/// the bar never rebuilds, the selected pill animates rather than jump-cuts,
/// and each tab keeps its scroll position while off-screen.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.name, required this.asset});

  final String name;
  final String asset;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  late final List<Widget> _tabs = [
    HomeScreen(name: widget.name, asset: widget.asset),
    const ActivityTrailsScreen(),
    const AddDevicesScreen(),
    const MySpacesScreen(),
    const CustomizeScreen(),
  ];

  /// Chrome behind each tab. `null` keeps the shared house photo (the
  /// glassy Home look); a solid color opts that tab out of it entirely —
  /// e.g. Activity Trails' plain white page. A tab can't reach up and
  /// repaint the shell's background itself (it's shared, persistent chrome
  /// drawn once, behind the IndexedStack), so this is the switch for it.
  static const List<Color?> _tabBackgrounds = [
    null, // Home
    Colors.white, // Activity Trails
    null, // Add Devices
    null, // My Spaces
    Colors.white, // Customize
  ];

  void _select(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;

    final gutter = (w * 0.045).clamp(14.0, 24.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final tabBackground = _tabBackgrounds[_index];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (tabBackground == null)
            Image.asset(
              'images/home_screen_bg.png',
              package: 'godrej_one_sdk',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          else
            ColoredBox(color: tabBackground),
          IndexedStack(index: _index, children: _tabs),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(gutter, 0, gutter, gap * 0.5),
                child: GlassyContainer(
                  isABottomBar: true,
                  height: barHeight,
                  width: double.infinity,
                  // The default hairline is white-on-white and disappears
                  // over a solid tab background (e.g. Activity Trails) —
                  // this dark, low-alpha border stays visible over both the
                  // photo and a plain white page.
                  borderExists: true,
                  borderColor: Colors.black.withValues(alpha: 0.06),
                  bottomBarSelectedIndex: _index,
                  bottomBarItems: [
                    BottomBarItem.icon(
                      Icons.home_filled,
                      tooltip: 'Home',
                      onTap: () => _select(0),
                    ),
                    BottomBarItem.icon(
                      Icons.access_time_filled,
                      tooltip: 'Activity Trails',
                      onTap: () => _select(1),
                    ),
                    BottomBarItem.icon(
                      Icons.workspaces_filled,
                      tooltip: 'Add Devices',
                      onTap: () => _select(2),
                    ),
                    BottomBarItem.asset(
                      'images/svgs/spaces.svg',
                      tooltip: 'My Spaces',
                      onTap: () => _select(3),
                    ),
                    BottomBarItem.icon(
                      Icons.add,
                      tooltip: 'Customize',
                      onTap: () => _select(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
