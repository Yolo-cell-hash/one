import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:godrej_one_sdk/screens/landing_page.dart';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: Colors.white,
      animationDuration: const Duration(seconds: 4),
      onInit: () {
        debugPrint("On Init");
      },
      onEnd: () {
        debugPrint("On End");
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
      nextScreen: const LandingPage(),
    );
  }
}
