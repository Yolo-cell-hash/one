import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

const _brand = Color(0xFF810055);

OverlayEntry? _current;

/// Shows a frosted pill with [message] just above the floating bottom bar,
/// then fades it out after [duration]. A new toast replaces one that's
/// still showing rather than stacking on top of it.
///
/// Drawn into the root overlay, so it sits above the shell's bottom bar
/// and survives the caller's page being popped.
void showElegantToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  _current?.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ElegantToast(
      message: message,
      duration: duration,
      onDismissed: () {
        if (_current == entry) _current = null;
        if (entry.mounted) entry.remove();
      },
    ),
  );
  _current = entry;
  overlay.insert(entry);
}

class _ElegantToast extends StatefulWidget {
  const _ElegantToast({
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_ElegantToast> createState() => _ElegantToastState();
}

class _ElegantToastState extends State<_ElegantToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 200),
  )..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    // Same formulas HomeShell uses for its bar, so the toast floats just
    // above it.
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    return Positioned(
      left: 24,
      right: 24,
      bottom: media.padding.bottom + barHeight + gap * 1.5,
      child: IgnorePointer(
        // Overlay entries sit outside any route's Material, so give the
        // text a proper default style instead of the debug fallback.
        child: Material(
          type: MaterialType.transparency,
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(curved),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: _brand,
                          fontFamily: 'GEG',
                          package: 'godrej_one_sdk',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
