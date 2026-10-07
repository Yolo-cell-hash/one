import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/screens/splash_screen.dart';
import 'package:godrej_one_sdk/providers/bottom_bar_provider.dart';

void main() => runApp(const MyApp());

Widget returnMainApp() {
  return MyApp();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BottomBarProvider())],
      child: MaterialApp(home: SplashScreen()),
    );
  }
}

Widget myApp() {
  return MyApp();
}
