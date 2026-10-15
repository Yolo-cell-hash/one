import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:godrej_one_sdk/providers/bottom_bar_provider.dart';
import 'package:godrej_one_sdk/screens/landing_page.dart';
import 'package:godrej_one_sdk/widgets/user_circle_avatar_onboarding.dart';

void main() {
  testWidgets('Capture verified board presentation flows', (tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3;
    final roboto = FontLoader('Roboto')..addFont(Future.value(ByteData.sublistView(File('C:/Flutter/flutter/engine/src/flutter/txt/third_party/fonts/Roboto-Regular.ttf').readAsBytesSync())));
    await roboto.load();
    final fonts = <String, String>{
      'packages/godrej_one_sdk/GEG': 'packages/godrej_one_sdk/fonts/GEG-BodyCopy.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    };
    for (final e in fonts.entries) {
      final f = FontLoader(e.key)..addFont(rootBundle.load(e.value));
      await f.load();
    }
    final boundaryKey = GlobalKey();
    final provider = BottomBarProvider();
    await tester.pumpWidget(ChangeNotifierProvider.value(value: provider,
      child: MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(fontFamily: 'Roboto'),
        builder: (context, child) => RepaintBoundary(key: boundaryKey, child: child!),
        home: const LandingPage())));
    await tester.runAsync(() async { await Future<void>.delayed(const Duration(seconds: 2)); });
    await tester.pumpAndSettle();
    final out = Directory(const String.fromEnvironment('BOARD_CAPTURE_DIR', defaultValue: '../marketing_video/captures'))..createSync(recursive: true);
    Future<void> shot(String name) async {
      print('CAPTURE $name');
      await tester.pump();
      final b = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final im = await b.toImage(pixelRatio: const int.fromEnvironment('BOARD_CAPTURE_SCALE', defaultValue: 3).toDouble());
        final bytes = await im.toByteData(format: ui.ImageByteFormat.png);
        await File('${out.path}/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
        im.dispose();
      });
      print('SAVED $name');
    }
    await shot('01_profile_riya');
    await tester.tap(find.byWidgetPredicate((w) => w is UserCircleAvatarOnboarding && w.name == 'Jason').first);
    await tester.pumpAndSettle();
    await shot('02_profile_jason');
    await tester.tap(find.byWidgetPredicate((w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == 'images/glassy_home.png'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pump(const Duration(milliseconds: 100));
    await shot('03_welcome_jason');
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.runAsync(() async { await Future<void>.delayed(const Duration(milliseconds: 2200)); });
    await tester.pumpAndSettle();
    expect(find.text('Hey, Jason!'), findsOneWidget);
    await shot('04_home');
    await tester.tap(find.byTooltip('My Spaces'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async { await Future<void>.delayed(const Duration(seconds: 1)); });
    await tester.pumpAndSettle();
    await shot('05_spaces');
    await tester.tap(find.text('Living Room'));
    await tester.pumpAndSettle();
    await shot('06_living_room');
    await tester.tap(find.byTooltip('Activity Trails'));
    await tester.pumpAndSettle();
    await shot('07_devices_all');
    await tester.tap(find.text('Locks'));
    await tester.pumpAndSettle();
    expect(find.text('Locks'), findsOneWidget);
    await shot('08_devices_locks');
    for (var i=1;i<=8;i++) {
      await tester.enterText(find.byType(TextField).first, 'Advantis'.substring(0,i));
      await tester.pumpAndSettle();
      await shot('typing_$i');
    }
    expect(find.text('Advantis GSL D1'), findsOneWidget);
    expect(find.text('Astron / Rion'), findsNothing);
    await shot('09_devices_search');
    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.text('Cameras'));
    await tester.pumpAndSettle();
    await shot('10_devices_cameras');
    await tester.tap(find.byTooltip('My Spaces'));
    await tester.pumpAndSettle();
    expect(find.text('Living Room'), findsOneWidget);
    await shot('11_preserved_room');
    await tester.pumpWidget(const SizedBox());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
