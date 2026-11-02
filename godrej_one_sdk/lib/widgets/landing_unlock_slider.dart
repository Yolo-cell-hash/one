import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

const _brand = Color(0xFF810055);
const _armedGreen = Color(0xFF22C55E);
const _failedRed = Color(0xFFEF4444);

const _doors = ['Back door', 'Front door', 'Balcony door'];

const _trackHeight = 75.0;
const _dismissTravel = 140.0;
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

/// The landing page's door locks: one hold-and-swipe track per door, in a
/// horizontal pager with a dots pill under it. Swiping the track changes
/// door; only the knob unlocks.
class LandingUnlockSlider extends StatefulWidget {
  const LandingUnlockSlider({super.key, this.onUnlocked, this.dismissal});

  /// Called with the door's name once it unlocks.
  final ValueChanged<String>? onUnlocked;

  /// Slides the locks off the bottom of the screen as it runs from 0 to 1.
  /// It slides rather than fades because a live blur can't fade. The current
  /// door is kept for when it comes back.
  final Animation<double>? dismissal;

  @override
  State<LandingUnlockSlider> createState() => _LandingUnlockSliderState();
}

class _LandingUnlockSliderState extends State<LandingUnlockSlider> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 30,
      child: AnimatedBuilder(
        animation: widget.dismissal ?? kAlwaysDismissedAnimation,
        builder: (_, child) {
          final t = widget.dismissal?.value ?? 0;
          return Visibility(
            visible: t < 1,
            maintainState: true,
            child: IgnorePointer(
              ignoring: t > 0,
              child: Transform.translate(
                offset: Offset(0, t * _dismissTravel),
                child: child,
              ),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _trackHeight,
              child: PageView.builder(
                controller: _pages,
                itemCount: _doors.length,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _DoorLock(
                    door: _doors[i],
                    onUnlocked: () => widget.onUnlocked?.call(_doors[i]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 9),
            _PageDots(count: _doors.length, current: _page),
          ],
        ),
      ),
    );
  }
}

/// Frosted pill holding one dot per door.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD9E0EE).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(7.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 9,
              height: 9,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == current
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }
}

/// One door's hold-and-swipe track.
class _DoorLock extends StatefulWidget {
  const _DoorLock({required this.door, this.onUnlocked});

  final String door;
  final VoidCallback? onUnlocked;

  @override
  State<_DoorLock> createState() => _DoorLockState();
}

class _DoorLockState extends State<_DoorLock> with TickerProviderStateMixin {
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
    return LayoutBuilder(
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
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_trackHeight / 2),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: const CustomPaint(painter: _GlassTrackPainter()),
                    ),
                  ),
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
                    child: _Label(
                      title: widget.door,
                      subtitle: 'Hold and swipe to unlock',
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
                    child: _Label(
                      title: 'Unlocked',
                      subtitle: 'The ${widget.door.toLowerCase()} is unlocked',
                    ),
                  ),
                ),
                Positioned(
                  left: knobLeft - _knobInsetY,
                  top: 0,
                  // Claims horizontal drags that start on the knob, so
                  // sliding it can't also turn the page behind it.
                  child: GestureDetector(
                    onHorizontalDragStart: (_) {},
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
                ),
              ],
            );
          },
        );
      },
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
        color: Colors.white.withValues(alpha: 0.35),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
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
      Paint()..color = Colors.white.withValues(alpha: 0.62),
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
