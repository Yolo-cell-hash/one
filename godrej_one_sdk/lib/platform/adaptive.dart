import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Whether [context] should follow Apple's conventions rather than Material's.
///
/// Reads the platform off the [Theme] instead of [defaultTargetPlatform] so a
/// `ThemeData.platform` override (or a widget test) can flip it.
///
/// Everything in the SDK that differs between iOS and Android branches on this,
/// and the Material branch is always the original, unchanged behavior.
bool isCupertino(BuildContext context) {
  final platform = Theme.of(context).platform;
  return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}

/// An icon with a Material glyph for Android and an SF Symbols-style glyph
/// for iOS.
class AdaptiveIcon {
  const AdaptiveIcon(this.material, this.cupertino);

  final IconData material;
  final IconData cupertino;

  IconData of(BuildContext context) =>
      isCupertino(context) ? cupertino : material;
}

/// The SDK's icon set. Each entry pairs the Material icon the Android UI was
/// designed with and its closest SF Symbols counterpart.
abstract final class AppIcons {
  static const home = AdaptiveIcon(
    Icons.home_filled,
    CupertinoIcons.house_fill,
  );
  static const activity = AdaptiveIcon(
    Icons.access_time_filled,
    CupertinoIcons.clock_fill,
  );
  static const devices = AdaptiveIcon(
    Icons.workspaces_filled,
    CupertinoIcons.circle_grid_hex_fill,
  );
  static const widgets = AdaptiveIcon(
    Icons.widgets,
    CupertinoIcons.square_grid_2x2_fill,
  );
  static const spaces = AdaptiveIcon(
    Icons.space_dashboard_outlined,
    CupertinoIcons.rectangle_3_offgrid,
  );
  static const add = AdaptiveIcon(Icons.add, CupertinoIcons.add);
  // Android overflow menus are vertical dots; iOS uses a horizontal ellipsis.
  static const more = AdaptiveIcon(
    Icons.more_vert_rounded,
    CupertinoIcons.ellipsis,
  );
  static const search = AdaptiveIcon(Icons.search, CupertinoIcons.search);
  static const lock = AdaptiveIcon(Icons.lock, CupertinoIcons.lock_fill);
  static const lockOpen = AdaptiveIcon(
    Icons.lock_open,
    CupertinoIcons.lock_open_fill,
  );
}

/// Neutral fill behind secondary controls, such as the "more" circle and the
/// "Add" pill. On iOS this is the system fill used by native capsule buttons;
/// on Android it stays the original grey.
Color secondaryControlFill(BuildContext context) => isCupertino(context)
    ? CupertinoColors.tertiarySystemFill.resolveFrom(context)
    : Colors.grey;

/// Picks the iOS status bar text color for the content behind it: white over
/// photos, black over plain light pages.
///
/// Only `statusBarBrightness` is set, and only on iOS. Android's status bar is
/// left exactly as the platform draws it today.
class AdaptiveStatusBar extends StatelessWidget {
  const AdaptiveStatusBar({
    super.key,
    required this.lightContent,
    required this.child,
  });

  /// True for white status bar text (for dark or busy backgrounds).
  final bool lightContent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isCupertino(context)) return child;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // statusBarBrightness describes the background, not the text.
      value: SystemUiOverlayStyle(
        statusBarBrightness: lightContent ? Brightness.dark : Brightness.light,
      ),
      child: child,
    );
  }
}

/// A fade-in page route that, on iOS, can also be dismissed with the native
/// edge-swipe back gesture. On Android it's a plain [PageRouteBuilder] fade,
/// identical to what it replaces.
class FadeSwipeBackRoute<T> extends PageRouteBuilder<T> {
  FadeSwipeBackRoute({required WidgetBuilder builder, super.transitionDuration})
    : super(pageBuilder: (context, _, _) => builder(context));

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!isCupertino(context)) {
      return FadeTransition(opacity: animation, child: child);
    }
    // Pushes and programmatic pops keep the brand fade: the Cupertino slide is
    // pinned fully on-screen until the user drags from the left edge, and then
    // the page follows their finger like any other iOS page. The widget tree
    // has the same shape in both states, so nothing loses state mid-gesture.
    final dragging = popGestureInProgress;
    return CupertinoRouteTransitionMixin.buildPageTransitions<T>(
      this,
      context,
      dragging ? animation : kAlwaysCompleteAnimation,
      secondaryAnimation,
      FadeTransition(
        opacity: dragging ? kAlwaysCompleteAnimation : animation,
        child: child,
      ),
    );
  }
}
