import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:godrej_one_sdk/screens/splash_screen.dart';

void main() => runApp(const MyApp());

Widget returnMainApp() {
  return MyApp();
}

const _brand = Color(0xFF810055);

/// Android keeps Material's defaults untouched. On iOS, drop the ink ripple
/// (iOS controls dim or highlight instead) and tint Cupertino widgets
/// (cursor, selection handles, search field) with the brand color.
final ThemeData _iosTheme = ThemeData(
  splashFactory: NoSplash.splashFactory,
  cupertinoOverrideTheme: const CupertinoThemeData(primaryColor: _brand),
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: defaultTargetPlatform == TargetPlatform.iOS ? _iosTheme : null,
      home: SplashScreen(),
    );
  }
}

Widget myApp() {
  return MyApp();
}
