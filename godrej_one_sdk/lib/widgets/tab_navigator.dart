import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/providers/bottom_bar_provider.dart';

/// Gives a bottom tab its own [Navigator], so pages pushed from it open
/// *inside* the tab — the shell's bottom bar stays put, and switching tabs
/// and back keeps you on whichever page you left.
///
/// The system back button / gesture is routed here first, but only while
/// [tabId] is the selected tab: the shell's [IndexedStack] keeps every tab
/// mounted offstage, and a page left open here mustn't swallow back presses
/// on another tab. Back then:
///   1. pops a page pushed inside this tab, if there is one;
///   2. otherwise, on any tab but Home, switches to the Home tab;
///   3. only on Home's root page is the pop let through, leaving the shell.
/// So Home is the anchor — you always pass through it on the way out.
///
/// Tab pages are see-through, sitting on the photo the shell draws behind
/// them. Flutter's default transition paints a solid surface color behind a
/// page while it animates, which would hide that photo until the transition
/// ends — [_transitions] turns the fill off.
class TabNavigator extends StatefulWidget {
  const TabNavigator({super.key, required this.tabId, required this.root});

  /// The id of the tab every back press falls back to.
  static const homeTabId = 'home';

  /// The tab's id in [BottomBarProvider].
  final String tabId;

  /// The tab's first page.
  final Widget root;

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

const _transitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: PredictiveBackPageTransitionsBuilder(
      fallbackColor: Colors.transparent,
    ),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
);

class _TabNavigatorState extends State<TabNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  /// Whether this tab's navigator has a page above its root to pop.
  bool _nestedCanPop = false;

  bool get _isHome => widget.tabId == TabNavigator.homeTabId;

  void _handleBack() {
    final navigator = _navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.maybePop();
    } else if (!_isHome) {
      context.read<BottomBarProvider>().selectById(TabNavigator.homeTabId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActiveTab = context.select<BottomBarProvider, bool>(
      (bar) => bar.selectedId == widget.tabId,
    );

    return PopScope<Object?>(
      canPop: !isActiveTab || (_isHome && !_nestedCanPop),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      // Tracks whether the nested stack has something to pop, the same
      // way NavigatorPopHandler does.
      child: NotificationListener<NavigationNotification>(
        onNotification: (notification) {
          if (notification.canHandlePop != _nestedCanPop) {
            setState(() => _nestedCanPop = notification.canHandlePop);
          }
          return false;
        },
        child: Theme(
          data: Theme.of(context).copyWith(pageTransitionsTheme: _transitions),
          child: Navigator(
            key: _navigatorKey,
            onGenerateRoute: (settings) => MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => widget.root,
            ),
          ),
        ),
      ),
    );
  }
}
