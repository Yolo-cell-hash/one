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

/// [material] on Android; its closest SF Symbols counterpart on iOS.
///
/// The UI is written against Material icons (including the ones stored in
/// model data, like device and stat glyphs), and every place that draws one
/// passes it through here. A glyph with no good SF Symbols match keeps its
/// Material shape on iOS too.
IconData adaptiveIcon(BuildContext context, IconData material) =>
    isCupertino(context) ? (_sfEquivalents[material] ?? material) : material;

// Not const: IconData overrides ==, which const map keys can't.
final Map<IconData, IconData> _sfEquivalents = {
  // Tabs and navigation.
  Icons.home_filled: CupertinoIcons.house_fill,
  Icons.access_time_filled: CupertinoIcons.clock_fill,
  Icons.workspaces_filled: CupertinoIcons.circle_grid_hex_fill,
  Icons.widgets: CupertinoIcons.square_grid_2x2_fill,
  Icons.space_dashboard_outlined: CupertinoIcons.rectangle_3_offgrid,
  Icons.add: CupertinoIcons.add,
  // Android overflow menus are vertical dots; iOS uses a horizontal ellipsis.
  Icons.more_vert_rounded: CupertinoIcons.ellipsis,
  Icons.search: CupertinoIcons.search,
  Icons.check: CupertinoIcons.checkmark_alt,
  Icons.close: CupertinoIcons.xmark,
  // Locks and device controls.
  Icons.lock: CupertinoIcons.lock_fill,
  Icons.lock_open: CupertinoIcons.lock_open_fill,
  Icons.lock_open_rounded: CupertinoIcons.lock_open_fill,
  Icons.power_settings_new: CupertinoIcons.power,
  Icons.shield: CupertinoIcons.shield_fill,
  Icons.shield_outlined: CupertinoIcons.shield,
  Icons.check_circle: CupertinoIcons.checkmark_circle_fill,
  Icons.circle: CupertinoIcons.circle_fill,
  Icons.brightness_6_outlined: CupertinoIcons.sun_max,
  Icons.video_library: CupertinoIcons.film,
  Icons.notifications_active: CupertinoIcons.bell_fill,
  Icons.notifications_none: CupertinoIcons.bell,
  Icons.schedule: CupertinoIcons.clock,
  Icons.settings: CupertinoIcons.gear_alt_fill,
  Icons.history: CupertinoIcons.arrow_counterclockwise,
  // Device kinds and stats (models/space.dart).
  Icons.wifi: CupertinoIcons.wifi,
  Icons.bluetooth: CupertinoIcons.bluetooth,
  Icons.battery_charging_full_outlined: CupertinoIcons.battery_charging,
  Icons.battery_5_bar_outlined: CupertinoIcons.battery_75_percent,
  Icons.videocam_outlined: CupertinoIcons.videocam,
  Icons.lightbulb_outline: CupertinoIcons.lightbulb,
  Icons.light_outlined: CupertinoIcons.lightbulb,
  Icons.sensors: CupertinoIcons.dot_radiowaves_left_right,
  Icons.tv: CupertinoIcons.tv,
  Icons.ac_unit: CupertinoIcons.snow,
  Icons.thermostat: CupertinoIcons.thermometer,
  Icons.speaker_outlined: CupertinoIcons.speaker_2,
  Icons.air: CupertinoIcons.wind,
  Icons.eco_outlined: CupertinoIcons.leaf_arrow_circlepath,
  Icons.filter_alt_outlined: CupertinoIcons.line_horizontal_3_decrease,
  Icons.tune: CupertinoIcons.slider_horizontal_3,
  Icons.bolt_outlined: CupertinoIcons.bolt,
  Icons.nightlight_outlined: CupertinoIcons.moon,
  Icons.wb_sunny_outlined: CupertinoIcons.sun_max,
};

/// Neutral fill behind secondary controls, such as the "more" circle and the
/// "Add" pill. On iOS this is the system fill used by native capsule buttons;
/// on Android it stays the original grey.
Color secondaryControlFill(BuildContext context) => isCupertino(context)
    ? CupertinoColors.tertiarySystemFill.resolveFrom(context)
    : Colors.grey;

/// The iOS back chevron for a page pushed inside a tab.
///
/// Android pages are left by the system back button, so this renders nothing
/// there. It also renders nothing at the root of a tab, where there's no page
/// to go back to. Tapping it goes through `maybePop`, so a page's [PopScope]
/// (e.g. "close the open device first") still applies.
class AdaptiveBackButton extends StatelessWidget {
  const AdaptiveBackButton({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    if (!isCupertino(context) || !canPop) return const SizedBox.shrink();
    return CupertinoNavigationBarBackButton(color: color);
  }
}

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
