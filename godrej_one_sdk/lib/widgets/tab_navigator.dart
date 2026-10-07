import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/providers/bottom_bar_provider.dart';

/// Gives a bottom tab its own [Navigator], so pages pushed from it open
/// *inside* the tab — the shell's bottom bar stays put, and switching tabs
/// and back keeps you on whichever page you left.
///
/// [NavigatorPopHandler] routes the system back button / gesture to this
/// navigator first, but only while [tabId] is the selected tab: the shell's
/// [IndexedStack] keeps every tab mounted offstage, and a page left open
/// here mustn't swallow back presses on another tab.
class TabNavigator extends StatefulWidget {
  const TabNavigator({super.key, required this.tabId, required this.root});

  /// The tab's id in [BottomBarProvider].
  final String tabId;

  /// The tab's first page.
  final Widget root;

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final isActiveTab = context.select<BottomBarProvider, bool>(
      (bar) => bar.selectedId == widget.tabId,
    );

    return NavigatorPopHandler<Object?>(
      enabled: isActiveTab,
      onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => widget.root,
        ),
      ),
    );
  }
}
