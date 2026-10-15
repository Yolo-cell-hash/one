// Frame-accurate capture of real app flows for the board film.
//
// Drives the actual Godrej One widgets (no mocks, no production changes) on a
// 390 x 844 pt phone at 4x density, pumping exactly one 60 fps frame at a
// time and saving every distinct frame. Interactions are real pointer
// gestures; their positions are written to the manifest so the film can
// draw touch indicators exactly where the app was touched.
//
// Run from `godrej_one/`:
//   flutter test test_film/film_capture_test.dart
//
// High-resolution copies of low-density assets (see
// marketing_video/v3/tools/upscale_assets.py) are placed in the image cache
// with a matching ImageInfo.scale, so layout is identical and only
// sharpness changes.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/providers/bottom_bar_provider.dart';
import 'package:godrej_one_sdk/screens/landing_page.dart';
import 'package:godrej_one_sdk/widgets/glassy_container.dart';
import 'package:godrej_one_sdk/widgets/landing_unlock_slider.dart';
import 'package:godrej_one_sdk/widgets/my_spaces_card.dart';
import 'package:godrej_one_sdk/widgets/user_circle_avatar_onboarding.dart';

const _logical = Size(390, 844);
const _density = 4.0;
const _frame = Duration(microseconds: 16667);
const _v3 = '../marketing_video/v3';

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
  }
  await loader.load();
}

class _Recorder {
  _Recorder(this.tester, this.boundary, this.dir);

  final WidgetTester tester;
  final GlobalKey boundary;
  final Directory dir;

  int frame = 0;
  final frames = <String>[];
  final events = <Map<String, Object?>>[];
  final markers = <String, int>{};
  final rects = <String, List<double>>{};
  Uint8List? _last;
  String? _lastName;
  int _unique = 0;
  final _watch = Stopwatch()..start();

  void mark(String name) => markers[name] = frame;

  void rect(String name, Finder finder) {
    final r = tester.getRect(finder);
    rects[name] = [r.left, r.top, r.width, r.height];
  }

  Future<void> _capture() async {
    final b = boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await b.toImage(pixelRatio: _density);
      final raw = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      final bytes = raw.buffer.asUint8List(raw.offsetInBytes, raw.lengthInBytes);
      if (_last != null && _same(_last!, bytes)) {
        frames.add(_lastName!);
        image.dispose();
        return;
      }
      final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      final name = 'u${(_unique++).toString().padLeft(5, '0')}.png';
      File('${dir.path}/$name').writeAsBytesSync(png.buffer.asUint8List());
      image.dispose();
      _last = Uint8List.fromList(bytes);
      _lastName = name;
      frames.add(name);
    });
    frame++;
    if (frame % 30 == 0) {
      // ignore: avoid_print
      print('frame $frame  unique $_unique  ${_watch.elapsed.inSeconds}s');
    }
  }

  static bool _same(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    final x = a.buffer.asUint64List(a.offsetInBytes, a.length ~/ 8);
    final y = b.buffer.asUint64List(b.offsetInBytes, b.length ~/ 8);
    for (var i = 0; i < x.length; i++) {
      if (x[i] != y[i]) return false;
    }
    return true;
  }

  /// Advances the app by [n] frames, capturing each.
  Future<void> tick([int n = 1]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(_frame);
      await _capture();
    }
  }

  /// A finger tap held for [holdFrames] before lifting.
  Future<void> tap(Finder finder, String label, {int holdFrames = 6, Offset nudge = Offset.zero}) async {
    final p = tester.getCenter(finder) + nudge;
    final g = await tester.startGesture(p);
    events.add({'type': 'tap', 'label': label, 'down': frame, 'up': frame + holdFrames, 'x': p.dx, 'y': p.dy});
    await tick(holdFrames);
    await g.up();
  }

  Future<void> write() async {
    final manifest = {
      'fps': 60,
      'logical': [_logical.width, _logical.height],
      'density': _density,
      'frames': frames,
      'markers': markers,
      'events': events,
      'rects': rects,
    };
    File('${dir.path}/manifest.json').writeAsStringSync(const JsonEncoder.withIndent(' ').convert(manifest));
  }
}

double _easeInOut(double t) => t < 0.5 ? 4 * t * t * t : 1 - (-2 * t + 2) * (-2 * t + 2) * (-2 * t + 2) / 2;

void main() {
  testWidgets('Capture board film flows at 60 fps', (tester) async {
    debugDisableShadows = false; // real soft shadows, as on device
    tester.view.physicalSize = _logical * _density;
    tester.view.devicePixelRatio = _density;
    tester.view.padding = const FakeViewPadding(top: 47 * _density, bottom: 34 * _density);
    tester.view.viewPadding = const FakeViewPadding(top: 47 * _density, bottom: 34 * _density);

    // Fonts: the SDK's GEG family (all weights), Roboto for Material defaults,
    // and Material icons.
    const geg = '../godrej_one_sdk/fonts';
    const mat = 'C:/Flutter/flutter/bin/cache/artifacts/material_fonts';
    await _loadFont('packages/godrej_one_sdk/GEG', [
      for (final f in ['BodyCopy', 'BodyCopyItalic', 'Light', 'LightItalic', 'Bold', 'ExtraBold', 'Headline', 'HeadlineItalic'])
        '$geg/GEG-$f.ttf',
    ]);
    await _loadFont('Roboto', [
      for (final f in ['regular', 'medium', 'bold', 'light', 'italic']) '$mat/roboto-$f.ttf',
    ]);
    await _loadFont('MaterialIcons', ['$mat/materialicons-regular.otf']);

    // High-resolution assets into the image cache, keyed exactly as the
    // app's own Image.asset calls will look them up.
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSizeBytes = 3 << 30;
    cache.maximumSize = 4000;
    final factors = (jsonDecode(File('$_v3/assets_hd/factors.json').readAsStringSync()) as Map).cast<String, num>();
    final hdWidths = <String, int>{};
    await tester.runAsync(() async {
      for (final e in factors.entries) {
        final provider = AssetImage(e.key, package: 'godrej_one_sdk');
        final key = await provider.obtainKey(const ImageConfiguration(bundle: null, devicePixelRatio: _density));
        final bytes = File('$_v3/assets_hd/${e.key.substring('images/'.length)}').readAsBytesSync();
        final codec = await ui.instantiateImageCodec(bytes);
        final image = (await codec.getNextFrame()).image;
        hdWidths[e.key] = image.width;
        cache.putIfAbsent(
          key,
          () => OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: image, scale: e.value.toDouble()))),
        );
      }
    });

    final boundaryKey = GlobalKey();
    final provider = BottomBarProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) => RepaintBoundary(key: boundaryKey, child: child!),
          home: const LandingPage(),
        ),
      ),
    );
    // Let any remaining (non-upscaled) assets decode for real.
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pump(_frame);
    }

    // Verify the cache is serving the high-resolution copies.
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(LandingPage));
      final stream = const AssetImage('images/landing_base_bg.png', package: 'godrej_one_sdk')
          .resolve(createLocalImageConfiguration(ctx));
      final info = await _first(stream);
      expect(info.image.width, hdWidths['images/landing_base_bg.png']);
      expect(info.scale, 2);
    });

    final out = Directory(const String.fromEnvironment('FILM_OUT', defaultValue: '$_v3/capture/frames'));
    if (out.existsSync()) out.deleteSync(recursive: true);
    out.createSync(recursive: true);
    final r = _Recorder(tester, boundaryKey, out);

    // ── Landing: choose a resident, then hold-and-swipe to unlock. ──────────
    r.mark('landing');
    r.rect('landing_slider', find.byType(LandingUnlockSlider));
    await r.tick(40);
    final jason = find.byWidgetPredicate((w) => w is UserCircleAvatarOnboarding && w.name == 'Jason');
    r.rect('avatars', jason);
    await r.tap(jason, 'jason');
    await r.tick(40);

    final knob = find.descendant(of: find.byType(LandingUnlockSlider), matching: find.byIcon(Icons.lock));
    final knobAt = tester.getCenter(knob);
    final slider = tester.getRect(find.byType(LandingUnlockSlider));
    final travel = slider.width - 2 * 7 - 65;
    final g = await tester.startGesture(knobAt);
    r.mark('hold_start');
    r.events.add({'type': 'hold', 'label': 'unlock', 'down': r.frame, 'x': knobAt.dx, 'y': knobAt.dy});
    await r.tick(80); // 1.2 s charge + a beat once armed
    r.mark('drag_start');
    const dragFrames = 26;
    var moved = 0.0;
    for (var i = 1; i <= dragFrames; i++) {
      final target = (travel + 6) * _easeInOut(i / dragFrames);
      await g.moveBy(Offset(target - moved, 0));
      moved = target;
      await r.tick();
    }
    r.events.last['up'] = r.frame;
    r.events.last['x2'] = knobAt.dx + moved;
    await g.up();
    r.mark('unlocked');
    await r.tick(66);

    // ── Launch into home: the personal welcome. ─────────────────────────────
    final home = find.byWidgetPredicate(
      (w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == 'images/glassy_home.png',
    );
    await r.tap(home, 'home', holdFrames: 5);
    r.mark('launch');
    await r.tick(300);
    expect(find.text('Hey, Jason!'), findsOneWidget);
    r.mark('home');
    await r.tick(70);

    // ── Home → Main door lock, straight onto its controls. ──────────────────
    final lockTile = find.ancestor(of: find.text('Main door lock'), matching: find.byType(GlassyContainer)).first;
    r.rect('lock_tile', lockTile);
    await r.tap(lockTile, 'lock_tile', nudge: const Offset(-40, 0));
    r.mark('lock_open');
    await r.tick(100);
    expect(find.text('Hold to Unlock'), findsOneWidget);

    // ── Its activity trail: who came in, how, and when. ─────────────────────
    final trailTile = find.text('Activity Trail').hitTestable();
    r.rect('trail_tile', trailTile);
    await r.tap(trailTile, 'trail');
    r.mark('trail_open');
    await r.tick(110);
    expect(find.text('Advantis IoT9'), findsOneWidget);

    // ── My Spaces tab → Living Room → Ceiling Lights. ───────────────────────
    final spacesTab = find.byTooltip('My Spaces');
    await r.tap(spacesTab, 'spaces_tab');
    r.mark('spaces');
    await r.tick(60);
    final living = find.ancestor(of: find.text('Living Room'), matching: find.byType(MySpacesCard));
    await r.tap(living, 'living_room');
    r.mark('room_open');
    await r.tick(75);
    expect(find.text('4 devices'), findsOneWidget);

    final lights = find.text('Ceiling Lights').hitTestable();
    await r.tap(lights, 'ceiling_lights');
    r.mark('lights_open');
    await r.tick(60);

    await r.tap(find.text('Ceiling Lights · On'), 'lights_off');
    r.mark('lights_off');
    await r.tick(36);
    await r.tap(find.text('Ceiling Lights · Off'), 'lights_on');
    r.mark('lights_on');
    await r.tick(30);

    // Brightness: drag from the current 70 % to 100 %.
    final sliderRect = tester.getRect(find.byType(Slider));
    r.rects['brightness'] = [sliderRect.left, sliderRect.top, sliderRect.width, sliderRect.height];
    const inset = 24.0;
    final trackW = sliderRect.width - 2 * inset;
    final from = Offset(sliderRect.left + inset + trackW * 0.7, sliderRect.center.dy);
    final sg = await tester.startGesture(from);
    r.mark('brightness');
    r.events.add({'type': 'drag', 'label': 'brightness', 'down': r.frame, 'x': from.dx, 'y': from.dy});
    await r.tick(6);
    const steps = 40;
    var dx = 0.0;
    for (var i = 1; i <= steps; i++) {
      final target = (trackW * 0.3 + 4) * _easeInOut(i / steps);
      await sg.moveBy(Offset(target - dx, 0));
      dx = target;
      await r.tick();
    }
    await r.tick(4);
    r.events.last['up'] = r.frame;
    r.events.last['x2'] = from.dx + dx;
    await sg.up();
    await r.tick(50);
    expect(find.text('100%'), findsOneWidget);
    r.mark('end');

    await r.write();
    // ignore: avoid_print
    print('captured ${r.frame} frames, ${r.frames.toSet().length} unique');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    debugDisableShadows = true;
    tester.view.reset();
  }, timeout: const Timeout(Duration(minutes: 90)));
}

Future<ImageInfo> _first(ImageStream stream) {
  final c = Completer<ImageInfo>();
  late ImageStreamListener l;
  l = ImageStreamListener((info, _) {
    c.complete(info);
    stream.removeListener(l);
  }, onError: (e, s) => c.completeError(e, s));
  stream.addListener(l);
  return c.future;
}
