import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/screens/home_shell.dart';
import 'package:godrej_one_sdk/service/user_name_onboarding_handler.dart';
import 'package:godrej_one_sdk/widgets/landing_top_content.dart';
import 'package:godrej_one_sdk/widgets/landing_unlock_slider.dart';
import 'package:godrej_one_sdk/widgets/user_circle_avatar_onboarding.dart';

const _launchDuration = Duration(milliseconds: 1900);
const _welcomeHold = Duration(milliseconds: 2000);

// Push-in that uncovers the sky: the welcome design frames the house at ~1.72x
// of the landing framing, anchored at the top left.
const _skyZoom = 0.72;

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
    with SingleTickerProviderStateMixin {
  static const _users = UserNameOnboardingHandler.users;

  late final AnimationController _launch = AnimationController(
    vsync: this,
    duration: _launchDuration,
  );

  final List<GlobalKey> _avatarKeys = List.generate(
    _users.length,
    (_) => GlobalKey(),
  );

  int _selected = 0;
  Rect? _flightStart;
  Timer? _timer;

  bool get _launching => _flightStart != null;

  @override
  void dispose() {
    _timer?.cancel();
    _launch.dispose();
    super.dispose();
  }

  /// Progress of one slice of the launch timeline, as a 0..1 value.
  double _seg(double begin, double end, [Curve curve = Curves.linear]) => curve
      .transform(((_launch.value - begin) / (end - begin)).clamp(0.0, 1.0));

  void _onHomeTap() {
    if (_launching) return;
    final avatar =
        _avatarKeys[_selected].currentContext?.findRenderObject() as RenderBox?;
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

  void _openHome() async {
    if (!mounted) return;

    final launchedIndex = _selected; // preserve chosen user

    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => HomeShell(
          name: _users[launchedIndex].name,
          asset: _users[launchedIndex].image,
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );

    setState(() {
      _timer?.cancel();
      _timer = null;
      _launch.reset();
      _flightStart = null;
      //
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _launch,
        builder: (context, _) {
          final uiOut = _seg(0, 0.35, Curves.easeOut);
          return Stack(
            children: [
              Positioned.fill(
                child: ClipRect(
                  child: Transform.scale(
                    scale: 1 + _skyZoom * _seg(0, 1, Curves.easeInOutCubic),
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'images/landing_base_bg.png',
                      package: 'godrej_one_sdk',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Opacity(opacity: 1 - uiOut, child: const _Haze()),
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
    );
  }

  Widget _landing() {
    return Stack(
      children: [
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: LandingTopContent(
            users: _users,
            selectedIndex: _selected,
            avatarKeys: _avatarKeys,
            onSelect: (index) => setState(() => _selected = index),
          ),
        ),

        Positioned(
          bottom: 227,
          left: 0,
          right: 0,
          child: Center(
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

        Positioned(
          left: 34,
          bottom: 177,
          child: Image.asset(
            'images/bell_icon.png',
            package: 'godrej_one_sdk',
            width: 65,
            height: 65,
          ),
        ),
        Positioned(
          right: 24,
          bottom: 177,
          child: Image.asset(
            'images/power_icon.png',
            package: 'godrej_one_sdk',
            width: 65,
            height: 65,
          ),
        ),

        const LandingUnlockSlider(),
      ],
    );
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
                  child: Image.asset(
                    'images/godrej_logo.png',
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

class _Haze extends StatelessWidget {
  const _Haze();

  @override
  Widget build(BuildContext context) {
    // White haze sampled from the design: clear down to 56%, ~48% white by 72%,
    // easing off at the bottom.
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.09),
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.41),
            Colors.white.withValues(alpha: 0.48),
            Colors.white.withValues(alpha: 0.47),
            Colors.white.withValues(alpha: 0.33),
          ],
          stops: const [0.0, 0.56, 0.60, 0.64, 0.68, 0.72, 0.86, 1.0],
        ),
      ),
    );
  }
}
