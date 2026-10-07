import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:godrej_one_sdk/widgets/glassy_container.dart';

const _brand = Color(0xFF810055);
const _green = Color(0xFF22C55E);

const _holdDuration = Duration(milliseconds: 1200);
const _unlockedHold = Duration(seconds: 5);

/// Glass pill with a round lock button: press and hold until the ring
/// fills to unlock; let go early and it resets. Relocks itself after a few
/// seconds, like the real lock does.
class HoldToUnlock extends StatefulWidget {
  const HoldToUnlock({
    super.key,
    required this.target,
    this.height = 76,
    this.onUnlocked,
  });

  /// What gets unlocked, for the hint — "main door".
  final String target;
  final double height;
  final VoidCallback? onUnlocked;

  @override
  State<HoldToUnlock> createState() => _HoldToUnlockState();
}

class _HoldToUnlockState extends State<HoldToUnlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: _holdDuration,
  )..addStatusListener(_onHoldStatus);

  bool _unlocked = false;
  Timer? _relockTimer;

  @override
  void dispose() {
    _relockTimer?.cancel();
    _hold.dispose();
    super.dispose();
  }

  void _onHoldStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _unlocked) return;
    HapticFeedback.heavyImpact();
    setState(() => _unlocked = true);
    widget.onUnlocked?.call();
    _relockTimer = Timer(_unlockedHold, () {
      if (!mounted) return;
      setState(() => _unlocked = false);
      _hold.animateBack(0, duration: const Duration(milliseconds: 400));
    });
  }

  void _start() {
    if (_unlocked) return;
    HapticFeedback.selectionClick();
    _hold.forward();
  }

  void _cancel() {
    if (_unlocked) return;
    _hold.animateBack(0, duration: const Duration(milliseconds: 250));
  }

  @override
  Widget build(BuildContext context) {
    final knob = widget.height - 16;

    return GlassyContainer(
      height: widget.height,
      width: double.infinity,
      padding: EdgeInsets.zero,
      borderExists: _unlocked,
      borderColor: const Color(0xFF8DFC63),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => _start(),
        onPointerUp: (_) => _cancel(),
        onPointerCancel: (_) => _cancel(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              SizedBox.square(
                dimension: knob,
                child: AnimatedBuilder(
                  animation: _hold,
                  builder: (context, _) => Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.85),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      CircularProgressIndicator(
                        value: _hold.value,
                        strokeWidth: 3,
                        color: _unlocked ? _green : _brand,
                        backgroundColor: Colors.transparent,
                      ),
                      Icon(
                        _unlocked ? Icons.lock_open_rounded : Icons.lock,
                        color: _unlocked ? _green : _brand,
                        size: knob * 0.36,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [...previous, ?current],
                  ),
                  child: Column(
                    key: ValueKey(_unlocked),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _unlocked ? 'Unlocked' : 'Hold to Unlock',
                        style: const TextStyle(
                          fontFamily: 'GEG',
                          package: 'godrej_one_sdk',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _brand,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _unlocked
                            ? 'Relocks automatically in a few seconds'
                            : 'Press and hold to unlock the ${widget.target}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'GEG',
                          package: 'godrej_one_sdk',
                          fontSize: 10,
                          color: _brand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
