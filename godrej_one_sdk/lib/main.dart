import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/screens/splash_screen.dart';
import 'package:godrej_one_sdk/providers/bottom_bar_provider.dart';
import 'package:godrej_one_sdk/providers/profile_store.dart';

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
      providers: [
        ChangeNotifierProvider(create: (_) => BottomBarProvider()),
        ChangeNotifierProvider(create: (_) => ProfileStore()..load()),
      ],
      child: MaterialApp(title: 'Godrej ONE', home: SplashScreen()),
    );
  }
}

Widget myApp() {
  return MyApp();
}
