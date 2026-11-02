import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/models/property.dart';
import 'package:godrej_one_sdk/models/space.dart';
import 'package:godrej_one_sdk/providers/bottom_bar_provider.dart';
import 'package:godrej_one_sdk/screens/home_shell.dart';
import 'package:godrej_one_sdk/service/show_elegant_toast.dart';
import 'package:godrej_one_sdk/service/user_name_onboarding_handler.dart';
import 'package:godrej_one_sdk/widgets/landing_properties_panel.dart';
import 'package:godrej_one_sdk/widgets/landing_top_content.dart';
import 'package:godrej_one_sdk/widgets/landing_unlock_slider.dart';
import 'package:godrej_one_sdk/widgets/user_circle_avatar_onboarding.dart';

const _brand = Color(0xFF810055);

final _panelScale = Tween<double>(begin: 0.94, end: 1);

const _launchDuration = Duration(milliseconds: 1900);
const _welcomeHold = Duration(milliseconds: 2000);

// The landing design frames the photo slightly tighter than cover, with the
// tower's top tucked behind the header card.
const _landingZoom = 1.124;
const _landingAnchor = Alignment(-0.25, 0.83);

// Push-in that uncovers the sky: the welcome design frames the house at ~1.72x
// of the full photo, anchored at the top left.
const _welcomeZoom = 1.72;

const _welcomeLineStyle = TextStyle(
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
  fontSize: 17,
  fontWeight: FontWeight.w300,
  letterSpacing: 4.7,
  color: Colors.white,
);

const _welcomeNameStyle = TextStyle(
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
  fontSize: 42,
  fontWeight: FontWeight.w300,
  color: Colors.white,
);

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  static const _users = UserNameOnboardingHandler.users;
  static const _properties = Property.all;

  late final AnimationController _launch = AnimationController(
    vsync: this,
    duration: _launchDuration,
  );

  /// Opens and closes the properties list: the card, the frosted photo, and
  /// the buttons and locks making way all move together on this.
  late final AnimationController _sheet =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 320),
        reverseDuration: const Duration(milliseconds: 220),
      )..addStatusListener((status) {
        // Drops the closed card from the tree.
        if (status == AnimationStatus.dismissed) setState(() {});
      });
  late final _sheetCurve = CurvedAnimation(
    parent: _sheet,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  final _avatarKey = GlobalKey();
  bool _imagesCached = false;

  int _selected = 0;
  int _property = 0;
  bool _propertiesOpen = false;
  bool _shellOpen = false;
  Rect? _flightStart;
  Timer? _timer;

  bool get _launching => _flightStart != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_imagesCached) return;
    _imagesCached = true;
    // Decoded ahead of time so nothing pops in blank the first time it's shown.
    for (final property in _properties) {
      precacheImage(property.backgroundImage, context);
      precacheImage(property.frostedImage, context);
      precacheImage(property.thumbnailImage, context);
    }
    precacheImage(
      const AssetImage('images/home_screen_bg.png', package: 'godrej_one_sdk'),
      context,
    );
    for (final space in demoSpaces.where((s) => s.id == 'entrance')) {
      precacheImage(
        AssetImage(space.image, package: 'godrej_one_sdk'),
        context,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sheetCurve.dispose();
    _sheet.dispose();
    _launch.dispose();
    super.dispose();
  }

  /// Progress of one slice of the launch timeline, as a 0..1 value.
  double _seg(double begin, double end, [Curve curve = Curves.linear]) => curve
      .transform(((_launch.value - begin) / (end - begin)).clamp(0.0, 1.0));

  void _setPropertiesOpen(bool open) {
    setState(() => _propertiesOpen = open);
    open ? _sheet.forward() : _sheet.reverse();
  }

  void _toggleProperties() => _setPropertiesOpen(!_propertiesOpen);

  void _selectProperty(int index) {
    _property = index;
    _setPropertiesOpen(false);
  }

  void _onHomeTap() {
    if (_launching || _shellOpen) return;
    final avatar = _avatarKey.currentContext?.findRenderObject() as RenderBox?;
    final page = context.findRenderObject() as RenderBox?;
    if (avatar == null || page == null) return;
    setState(() {
      _flightStart =
          avatar.localToGlobal(Offset.zero, ancestor: page) & avatar.size;
    });
    _launch.forward().whenComplete(() {
      _timer = Timer(_welcomeHold, _openHome);
    });
  }

  /// Straight to the Video Door Bell, skipping the welcome animation. It
  /// opens over the Home tab, so back still passes through Home.
  void _openVdb() {
    if (_launching || _shellOpen) return;
    _openHome(openVdb: true);
  }

  void _openHome({bool openVdb = false}) async {
    if (!mounted) return;
    _shellOpen = true;

    final launchedIndex = _selected; // preserve chosen user

    // The selected tab lives in an app-wide provider, so it would otherwise
    // survive leaving the shell — always come back in on Home.
    context.read<BottomBarProvider>().selectById('home');

    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => HomeShell(
          name: _users[launchedIndex].name,
          asset: _users[launchedIndex].image,
          openVdbOnStart: openVdb,
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );

    setState(() {
      _shellOpen = false;
      _timer?.cancel();
      _timer = null;
      _launch.reset();
      _flightStart = null;
      //
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back closes the properties list before leaving the page.
      canPop: !_propertiesOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _setPropertiesOpen(false);
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _launch,
          builder: (context, _) {
            final uiOut = _seg(0, 0.35, Curves.easeOut);
            final zoomIn = _seg(0, 1, Curves.easeInOutCubic);
            return Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: Transform.scale(
                      scale: lerpDouble(_landingZoom, _welcomeZoom, zoomIn)!,
                      alignment: Alignment.lerp(
                        _landingAnchor,
                        Alignment.topLeft,
                        zoomIn,
                      )!,
                      // Cross-fades the photo when another property is picked.
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        layoutBuilder: (current, previous) => Stack(
                          fit: StackFit.expand,
                          children: [...previous, ?current],
                        ),
                        child: _PropertyPhoto(
                          key: ValueKey(_property),
                          property: _properties[_property],
                          frost: _sheetCurve,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: _launching,
                    child: Opacity(opacity: 1 - uiOut, child: _landing()),
                  ),
                ),
                if (_launching) ..._flight(context),
                if (_launching) _welcome(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _landing() {
    return Stack(
      children: [
        Positioned(
          top: 71,
          left: 16,
          right: 16,
          child: LandingTopContent(
            user: _users[_selected],
            avatarKey: _avatarKey,
            locality: _properties[_property].locality,
            propertiesOpen: _propertiesOpen,
            // The card shows one resident; tapping moves on to the next.
            onAvatarTap: () =>
                setState(() => _selected = (_selected + 1) % _users.length),
            onPropertyTap: _toggleProperties,
          ),
        ),

        Positioned.fill(
          child: IgnorePointer(
            ignoring: _propertiesOpen,
            child: FadeTransition(
              opacity: ReverseAnimation(_sheetCurve),
              child: Stack(children: _buttons()),
            ),
          ),
        ),

        if (_propertiesOpen || !_sheet.isDismissed) ..._propertiesOverlay(),

        LandingUnlockSlider(dismissal: _sheetCurve),
      ],
    );
  }

  /// The properties card, dropping out of the property button.
  List<Widget> _propertiesOverlay() {
    return [
      // Tap anywhere around the card to close it.
      if (_propertiesOpen)
        Positioned.fill(
          top: 202,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleProperties,
          ),
        ),
      Positioned(
        top: 212,
        left: 24,
        right: 24,
        bottom: 24,
        child: LayoutBuilder(
          builder: (context, constraints) => Align(
            alignment: Alignment.topCenter,
            // Shrinks the card on short screens rather than overflowing.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: constraints.maxWidth,
                child: IgnorePointer(
                  ignoring: !_propertiesOpen,
                  child: RepaintBoundary(
                    child: FadeTransition(
                      opacity: _sheetCurve,
                      child: ScaleTransition(
                        scale: _panelScale.animate(_sheetCurve),
                        alignment: const Alignment(0.85, -1),
                        child: LandingPropertiesPanel(
                          properties: _properties,
                          selectedIndex: _property,
                          onSelect: _selectProperty,
                          onAddProperty: () => showElegantToast(
                            context,
                            'Adding properties coming soon',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  /// Home, doorbell and camera — hidden while the properties list is open.
  List<Widget> _buttons() {
    return [
      Positioned(
        bottom: 227,
        left: 0,
        right: 0,
        child: Center(
          child: Semantics(
            button: true,
            label: 'Home',
            child: GestureDetector(
              onTap: _onHomeTap,
              child: Image.asset(
                'images/glassy_home.png',
                package: 'godrej_one_sdk',
                width: 65,
                height: 65,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 34,
        bottom: 177,
        child: _GlassRoundButton(
          label: 'Video Door Bell',
          onTap: _openVdb,
          child: const _VdbGlyph(),
        ),
      ),
      Positioned(
        right: 32,
        bottom: 177,
        child: _GlassRoundButton(
          label: 'Cameras',
          onTap: () => showElegantToast(context, 'Cameras coming soon'),
          child: const Icon(Icons.videocam_rounded, size: 36, color: _brand),
        ),
      ),
    ];
  }

  /// The selected resident lifting off the row and dissolving into the sky.
  List<Widget> _flight(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final start = _flightStart!;
    final target = Offset(size.width / 2, size.height * 0.30);

    final rise = _seg(0.05, 0.62, Curves.easeInCubic);
    final drift = _seg(0.05, 0.62, Curves.easeInOut);
    final centre = Offset(
      lerpDouble(start.center.dx, target.dx, drift)!,
      lerpDouble(start.center.dy, target.dy, rise)!,
    );
    final diameter = lerpDouble(start.width, 84, drift)!;

    final bloom = _seg(0.42, 0.90, Curves.easeOut);
    final bloomSize = lerpDouble(60, 280, bloom)!;

    return [
      Positioned(
        left: target.dx - bloomSize / 2,
        top: target.dy - bloomSize / 2,
        width: bloomSize,
        height: bloomSize,
        child: IgnorePointer(
          child: Opacity(
            opacity: math.sin(math.pi * bloom) * 0.5,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white, Color(0x00FFFFFF)],
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: centre.dx - diameter / 2,
        top: centre.dy - diameter / 2,
        width: diameter,
        height: diameter,
        child: IgnorePointer(
          child: Opacity(
            opacity: 1 - _seg(0.40, 0.62, Curves.easeIn),
            child: UserCircleAvatarOnboarding(
              name: _users[_selected].name,
              image: AssetImage(
                _users[_selected].image,
                package: 'godrej_one_sdk',
              ),
              selected: true,
              radius: diameter / 2,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _welcome() {
    final logoIn = _seg(0.52, 0.82, Curves.easeOut);
    final lineIn = _seg(0.60, 0.90, Curves.easeOut);
    final nameIn = _seg(0.68, 1.0, Curves.easeOut);

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: 99,
              left: 0,
              right: 0,
              child: _FadeUp(
                progress: logoIn,
                travel: -10,
                child: Center(
                  child: SvgPicture.asset(
                    'images/svgs/godrej_logo_white.svg',
                    package: 'godrej_one_sdk',
                    width: 84,
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, -0.19),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FadeUp(
                    progress: lineIn,
                    travel: 14,
                    child: const Text('WELCOME HOME', style: _welcomeLineStyle),
                  ),
                  const SizedBox(height: 2),
                  _FadeUp(
                    progress: nameIn,
                    travel: 16,
                    child: Text(
                      _users[_selected].name,
                      style: _welcomeNameStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FadeUp extends StatelessWidget {
  const _FadeUp({
    required this.progress,
    required this.travel,
    required this.child,
  });

  final double progress;
  final double travel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: progress,
      child: Transform.translate(
        offset: Offset(0, travel * (1 - progress)),
        child: child,
      ),
    );
  }
}

/// 65px frosted circle matching `glassy_home.png`, for the landing page's
/// other round buttons.
class _GlassRoundButton extends StatelessWidget {
  const _GlassRoundButton({
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 65,
          height: 65,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEDEBEA), Color(0xFFDEDAD8), Color(0xFFF0E9E3)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// The doorbell unit: a brand capsule with the camera lens over the button.
class _VdbGlyph extends StatelessWidget {
  const _VdbGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 21,
      height: 41,
      decoration: BoxDecoration(
        color: _brand,
        borderRadius: BorderRadius.circular(10.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 13,
            height: 13,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.2),
            ),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
            ),
          ),
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

/// A property's photo, with its frosted copy faded in over it by [frost].
class _PropertyPhoto extends StatelessWidget {
  const _PropertyPhoto({
    super.key,
    required this.property,
    required this.frost,
  });

  final Property property;
  final Animation<double> frost;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(image: property.backgroundImage, fit: BoxFit.cover),
        RepaintBoundary(
          child: FadeTransition(
            opacity: frost,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 12,
                sigmaY: 12,
                tileMode: TileMode.clamp,
              ),
              child: Image(image: property.frostedImage, fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }
}
