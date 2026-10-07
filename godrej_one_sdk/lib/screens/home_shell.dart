import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/platform/adaptive.dart';
import 'package:godrej_one_sdk/screens/activity_trails_screen.dart';
import 'package:godrej_one_sdk/screens/add_devices_screen.dart';
import 'package:godrej_one_sdk/screens/customize_screen.dart';
import 'package:godrej_one_sdk/screens/home_screen.dart';
import 'package:godrej_one_sdk/screens/my_spaces_screen.dart';
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
  const HomeShell({super.key, required this.name, required this.asset});

  final String name;
  final String asset;

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
        root: HomeScreen(name: widget.name, asset: widget.asset),
      ),
      const ActivityTrailsScreen(),
      const AddDevicesScreen(),
      MySpacesScreen(name: widget.name, asset: widget.asset),
      const CustomizeScreen(),
    ];
  }

  /// Chrome behind each tab. `null` keeps the shared house photo (the
  /// glassy Home look); a solid color opts that tab out of it entirely —
  /// e.g. Activity Trails' and Customize's plain white pages. A tab can't
  /// reach up and repaint the shell's background itself (it's shared,
  /// persistent chrome drawn once, behind the IndexedStack), so this is the
  /// switch for it. Index must line up with [BottomBarProvider.defaultItems].
  static const List<Color?> _tabBackgrounds = [
    null, // Home
    Colors.white, // Activity Trails
    Colors.white, // Add Devices
    null, // My Spaces
    Colors.white, // Customize
  ];

  BottomBarItem _toBarItem(
    BuildContext context,
    BottomBarItemSpec spec,
    VoidCallback onTap,
  ) {
    final assetPath = spec.assetPath;
    return assetPath != null
        ? BottomBarItem.asset(
            spec.id,
            assetPath,
            tooltip: spec.tooltip,
            onTap: onTap,
          )
        : BottomBarItem.icon(
            spec.id,
            adaptiveIcon(context, spec.icon!),
            tooltip: spec.tooltip,
            onTap: onTap,
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

    return AdaptiveStatusBar(
      lightContent: tabBackground == null,
      child: Scaffold(
        backgroundColor: Colors.white,
        // An iOS tab bar stays put and is covered by the keyboard; it doesn't
        // ride up above it.
        resizeToAvoidBottomInset: !isCupertino(context),
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
                    bottomBarSelectedIndex: index,
                    bottomBarItems: [
                      for (var i = 0; i < barProvider.items.length; i++)
                        _toBarItem(
                          context,
                          barProvider.items[i],
                          () => barProvider.select(i),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
