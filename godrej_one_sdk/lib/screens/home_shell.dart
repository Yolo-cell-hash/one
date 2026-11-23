import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/screens/activity_trails_screen.dart';
import 'package:godrej_one_sdk/screens/add_devices_screen.dart';
import 'package:godrej_one_sdk/screens/assistant_screen.dart';
import 'package:godrej_one_sdk/screens/customize_screen.dart';
import 'package:godrej_one_sdk/screens/home_screen.dart';
import 'package:godrej_one_sdk/screens/my_spaces_screen.dart';
import 'package:godrej_one_sdk/screens/account/profile_screen.dart';
import 'package:godrej_one_sdk/widgets/glassy_container.dart';
import 'package:godrej_one_sdk/widgets/tab_navigator.dart';
import 'package:godrej_one_sdk/providers/bottom_bar_provider.dart';

/// Persistent chrome for the bottom-tab flow: the background image and the
/// floating bottom bar are built once, here, and stay in place while
/// [IndexedStack] swaps which tab's body is visible.
///
/// Which tab is selected lives in [BottomBarProvider], not local state —
/// tapping a bar icon calls `provider.select(i)`, so any other part of the
/// app can read or drive the active tab too. The bar's items are built
/// straight from `provider.items`, so there is exactly one list of
/// {id, icon, tooltip} in the app; nothing here can drift out of sync with
/// it.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.openVdbOnStart = false});

  /// Opens the Video Door Bell over the Home tab on arrival.
  final bool openVdbOnStart;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      TabNavigator(
        tabId: 'home',
        root: HomeScreen(openVdbOnStart: widget.openVdbOnStart),
      ),
      const ActivityTrailsScreen(),
      const AddDevicesScreen(),
      const MySpacesScreen(),
      const AssistantScreen(),
      const TabNavigator(tabId: 'customize', root: CustomizeScreen()),
      const ProfileScreen(),
    ];
  }

  /// Chrome behind each tab. `null` keeps the shared house photo (the
  /// glassy Home look); a solid color opts that tab out of it entirely —
  /// e.g. Activity Trails' and Customize's plain white pages. A tab can't
  /// reach up and repaint the shell's background itself (it's shared,
  /// persistent chrome drawn once, behind the IndexedStack), so this is the
  /// switch for it. Index must line up with [BottomBarProvider.defaultItems].
  static const List<Color?> _tabBackgrounds = [
    Colors.white, // Home — draws its own brand header
    Colors.white, // Activity Trails
    Colors.white, // Add Devices
    null, // My Spaces
    Colors.white, // Gia
    Colors.white, // Customize
    Colors.white, // Profile
  ];

  /// The bar shows five slots: the first four tabs, then a last slot that's
  /// Gia — or Customize or Profile while one of those is open. Tapping it
  /// opens Gia; long-pressing it opens Customize.
  static const _lastSlot = 4;

  BottomBarItem _toBarItem(
    BottomBarItemSpec spec,
    VoidCallback onTap, {
    VoidCallback? onLongPress,
  }) {
    final assetPath = spec.assetPath;
    // A tooltip would take the long press for itself.
    final tooltip = onLongPress == null ? spec.tooltip : null;
    return assetPath != null
        ? BottomBarItem.asset(
            spec.id,
            assetPath,
            tooltip: tooltip,
            onTap: onTap,
            onLongPress: onLongPress,
            longPressHint: onLongPress == null ? null : 'Customize',
            label: tooltip == null ? spec.tooltip : null,
          )
        : BottomBarItem.icon(
            spec.id,
            spec.icon!,
            tooltip: tooltip,
            onTap: onTap,
            onLongPress: onLongPress,
            longPressHint: onLongPress == null ? null : 'Customize',
            label: tooltip == null ? spec.tooltip : null,
          );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;

    final gutter = (w * 0.045).clamp(14.0, 24.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);
    final barHeight = (w * 0.19).clamp(66.0, 84.0);

    final barProvider = context.watch<BottomBarProvider>();
    final index = barProvider.selectedIndex;
    final tabBackground = _tabBackgrounds[index];
    final slots = [
      for (var i = 0; i < _lastSlot; i++) i,
      index > _lastSlot ? index : _lastSlot,
    ];

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
          IndexedStack(index: index, children: _tabs),
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
                  bottomBarSelectedIndex: slots.indexOf(index),
                  bottomBarItems: [
                    for (final i in slots.take(_lastSlot))
                      _toBarItem(
                        barProvider.items[i],
                        () => barProvider.select(i),
                      ),
                    _toBarItem(
                      barProvider.items[slots.last],
                      () => barProvider.select(_lastSlot),
                      onLongPress: () {
                        HapticFeedback.mediumImpact();
                        barProvider.selectById('customize');
                      },
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
