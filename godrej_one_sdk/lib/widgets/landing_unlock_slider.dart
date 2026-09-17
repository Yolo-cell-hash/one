import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

const _brand = Color(0xFF810055);
const _armedGreen = Color(0xFF22C55E);
const _failedRed = Color(0xFFEF4444);

const _trackHeight = 75.0;
const _knobSize = 65.0;
const _knobInsetX = 7.0;
const _knobInsetY = 5.0;
const _labelGap = 15.0;
const _ringBoxSize = _knobSize + 2 * _knobInsetY;
const _ringStroke = 3.0;

const _holdDuration = Duration(milliseconds: 1200);
const _unlockThreshold = 0.85;
const _unlockedHold = Duration(milliseconds: 2500);

const _titleStyle = TextStyle(
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: _brand,
);

const _subtitleStyle = TextStyle(
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
  fontSize: 10,
  color: _brand,
);

enum _Phase { idle, charging, armed, failed, unlocked, relocking }

class LandingUnlockSlider extends StatefulWidget {
  const LandingUnlockSlider({super.key, this.onUnlocked});

  final VoidCallback? onUnlocked;

  @override
  State<LandingUnlockSlider> createState() => _LandingUnlockSliderState();
}

class _LandingUnlockSliderState extends State<LandingUnlockSlider>
    with TickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: _holdDuration,
  )..addStatusListener(_onHoldStatus);

  late final AnimationController _slide = AnimationController(vsync: this);

  late final AnimationController _ringFade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
    reverseDuration: const Duration(milliseconds: 300),
  );

  _Phase _phase = _Phase.idle;
  int? _pointer;
  Timer? _timer;

  static double _travelFor(double trackWidth) =>
      trackWidth - 2 * _knobInsetX - _knobSize;

  @override
  void dispose() {
    _timer?.cancel();
    _hold.dispose();
    _slide.dispose();
    _ringFade.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_pointer != null) return;
    if (_phase != _Phase.idle && _phase != _Phase.failed) return;
    _pointer = event.pointer;
    _timer?.cancel();
    setState(() => _phase = _Phase.charging);
    _ringFade.forward();
    _hold.forward(from: 0);
  }

  void _onHoldStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _phase != _Phase.charging) {
      return;
    }
    setState(() => _phase = _Phase.armed);
    HapticFeedback.mediumImpact();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer || _phase != _Phase.armed) return;
    _slide.value += event.localDelta.dx / _travelFor(context.size!.width);
    if (_slide.value == 1) {
      _pointer = null;
      _unlock();
    }
  }

  void _onPointerEnd(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    if (_phase == _Phase.armed && _slide.value >= _unlockThreshold) {
      _unlock();
    } else if (_phase == _Phase.charging || _phase == _Phase.armed) {
      _fail();
    }
  }

  void _fail() {
    _hold.stop();
    setState(() => _phase = _Phase.failed);
    Vibration.vibrate(preset: VibrationPreset.doubleBuzz);
    _slide.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
    _timer = Timer(const Duration(milliseconds: 600), () {
      _ringFade.reverse().whenComplete(() {
        if (_phase != _Phase.failed) return;
        _hold.value = 0;
        setState(() => _phase = _Phase.idle);
      });
    });
  }

  void _unlock() {
    setState(() => _phase = _Phase.unlocked);
    _slide
        .animateTo(
          1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        )
        .whenComplete(() {
          HapticFeedback.heavyImpact();
          widget.onUnlocked?.call();
        });
    _timer = Timer(_unlockedHold, _relock);
  }

  void _relock() {
    setState(() => _phase = _Phase.relocking);
    _ringFade.reverse();
    _slide
        .animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        )
        .whenComplete(() {
          _hold.value = 0;
          setState(() => _phase = _Phase.idle);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 34,
      height: _trackHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final travel = _travelFor(constraints.maxWidth);
          return AnimatedBuilder(
            animation: Listenable.merge([_hold, _slide, _ringFade]),
            builder: (context, _) {
              final knobLeft = _knobInsetX + travel * _slide.value;
              final unlocked = _phase == _Phase.unlocked;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(
                    child: CustomPaint(painter: _GlassTrackPainter()),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: knobLeft + _knobSize + _knobInsetX,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _armedGreen.withValues(
                          alpha: 0.16 * (_slide.value * 4).clamp(0.0, 1.0),
                        ),
                        borderRadius: BorderRadius.circular(_trackHeight / 2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: _knobInsetX + _knobSize + _labelGap,
                    right: 16,
                    top: 24,
                    child: Opacity(
                      opacity: (1 - _slide.value * 2).clamp(0.0, 1.0),
                      child: const _Label(
                        title: 'Hold and Swipe to unlock',
                        subtitle: 'Unlock the main door',
                      ),
                    ),
                  ),
                  Positioned(
                    left: 28,
                    right: _knobInsetX + _knobSize + _labelGap,
                    top: 24,
                    child: AnimatedOpacity(
                      opacity: unlocked ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const _Label(
                        title: 'Unlocked',
                        subtitle: 'The main door is unlocked',
                      ),
                    ),
                  ),
                  Positioned(
                    left: knobLeft - _knobInsetY,
                    top: 0,
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: _onPointerDown,
                      onPointerMove: _onPointerMove,
                      onPointerUp: _onPointerEnd,
                      onPointerCancel: _onPointerEnd,
                      child: SizedBox.square(
                        dimension: _ringBoxSize,
                        child: CustomPaint(
                          painter: _RingPainter(
                            progress: _hold.value,
                            color: _phase == _Phase.failed
                                ? _failedRed
                                : _armedGreen,
                            opacity: _ringFade.value,
                          ),
                          child: Center(child: _Knob(unlocked: unlocked)),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Knob extends StatelessWidget {
  const _Knob({required this.unlocked});

  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _knobSize,
      height: _knobSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          unlocked ? Icons.lock_open : Icons.lock,
          key: ValueKey(unlocked),
          color: _brand,
          size: 24,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: _titleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: _subtitleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _GlassTrackPainter extends CustomPainter {
  const _GlassTrackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(
      shape,
      Paint()..color = Colors.white.withValues(alpha: 0.93),
    );

    // Soft inner shade on the top/left edge, like the frosted glass in the design.
    canvas.save();
    canvas.clipRRect(shape);
    canvas.drawRRect(
      shape.shift(const Offset(2, 2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Colors.black.withValues(alpha: 0.07)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.restore();

    canvas.drawRRect(
      shape.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_GlassTrackPainter oldDelegate) => false;
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.opacity,
  });

  final double progress;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity == 0) return;
    final ring = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.width / 2 - 0.5 - _ringStroke / 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _ringStroke;

    canvas.drawOval(
      ring,
      paint..color = color.withValues(alpha: 0.18 * opacity),
    );
    if (progress == 0) return;
    canvas.drawArc(
      ring,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity;
}
