import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:godrej_one_sdk/platform/adaptive.dart';
import 'package:godrej_one_sdk/screens/landing_page.dart';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// The splash package always leaves with a [MaterialPageRoute], which on iOS
  /// slides the landing page in from the right like a pushed detail screen.
  /// iOS apps crossfade out of their launch screen instead, so on iOS the
  /// package is given no `nextScreen` and the hand-off happens here.
  void _crossfadeToLanding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => const LandingPage(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cupertino = isCupertino(context);
    return AdaptiveStatusBar(
      lightContent: false,
      child: FlutterSplashScreen.fadeIn(
        backgroundColor: Colors.white,
        animationDuration: const Duration(seconds: 4),
        onInit: () {
          debugPrint("On Init");
        },
        onEnd: () {
          debugPrint("On End");
          if (cupertino) _crossfadeToLanding();
        },
        childWidget: SizedBox(
          height: 200,
          width: 200,
          child: Image.asset(
            "images/godrej_logo.png",
            package: "godrej_one_sdk",
          ),
        ),
        onAnimationEnd: () => debugPrint("On Fade In End"),
        nextScreen: cupertino ? null : const LandingPage(),
      ),
    );
  }
}
