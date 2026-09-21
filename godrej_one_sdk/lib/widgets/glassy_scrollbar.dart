import 'dart:async';

import 'package:flutter/material.dart';

const _brand = Color(0xFF810055);

/// A slim, glassy scroll indicator that sits over the right edge of a scroll
/// view and shows how much content is left.
///
/// It is purely an indicator: taps and drags pass straight through to the
/// content below. It hides itself when there is nothing to scroll, and settles
/// back to [idleOpacity] a moment after scrolling stops so it never competes
/// with the cards.
class GlassyScrollbar extends StatefulWidget {
  const GlassyScrollbar({
    super.key,
    required this.controller,
    required this.child,
    this.thickness = 3,
    this.rightInset = 6,
    this.margin = const EdgeInsets.symmetric(vertical: 10),
    this.heightFactor = 0.5,
    this.maxTrackHeight = 160,
    this.minThumbLength = 22,
    this.thumbScale = 0.55,
    this.trackColor = const Color(0x2EFFFFFF),
    this.thumbColor = _brand,
    this.idleOpacity = 0.45,
  });

  /// Must be the same controller the [child] scroll view uses.
  final ScrollController controller;
  final Widget child;

  final double thickness;

  /// Gap between the indicator and the right edge of the scroll view.
  final double rightInset;

  /// Space left above and below the track's available band — use the bottom
  /// inset to keep it clear of a floating bottom bar.
  final EdgeInsets margin;

  /// Share of the available vertical band (after [margin]) the track
  /// occupies, centered within it. Keeps the indicator a short, discreet mark
  /// rather than a rail running the full height of the screen.
  final double heightFactor;

  /// Upper bound on the track's absolute height, applied after [heightFactor].
  final double maxTrackHeight;

  final double minThumbLength;

  /// Shrinks the thumb relative to its true viewport/content proportion, so
  /// it reads as a short mark rather than filling most of the track.
  final double thumbScale;

  final Color trackColor;
  final Color thumbColor;

  /// Opacity once scrolling has stopped. Full opacity while scrolling.
  final double idleOpacity;

  @override
  State<GlassyScrollbar> createState() => _GlassyScrollbarState();
}

class _GlassyScrollbarState extends State<GlassyScrollbar> {
  Timer? _idleTimer;
  bool _scrolling = false;

  @override
  void initState() {
    super.initState();
    // The controller has no clients until the first layout pass, so nudge a
    // rebuild once the scroll view has measured itself.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _rebuildAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void _markScrolling() {
    _idleTimer?.cancel();
    if (!_scrolling) setState(() => _scrolling = true);
    _idleTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _scrolling = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      // Fires when the content grows or shrinks without a scroll happening.
      onNotification: (_) {
        _rebuildAfterFrame();
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification ||
              notification is ScrollStartNotification) {
            _markScrolling();
          }
          return false;
        },
        child: Stack(
          children: [
            widget.child,
            Positioned(
              top: widget.margin.top,
              bottom: widget.margin.bottom,
              right: widget.rightInset,
              width: widget.thickness,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _scrolling ? 1 : widget.idleOpacity,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOut,
                  child: AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, _) => LayoutBuilder(
                      builder: (context, constraints) {
                        final trackHeight =
                            (constraints.maxHeight * widget.heightFactor).clamp(
                              widget.minThumbLength,
                              widget.maxTrackHeight,
                            );
                        // Center the short track within the full band.
                        return Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: trackHeight,
                            width: widget.thickness,
                            child: _buildIndicator(trackHeight),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(double trackHeight) {
    final controller = widget.controller;
    if (!controller.hasClients || trackHeight <= 0) {
      return const SizedBox.shrink();
    }

    // A controller attached to more than one view has no single position.
    final position = controller.positions.length == 1
        ? controller.position
        : null;
    if (position == null || !position.hasContentDimensions) {
      return const SizedBox.shrink();
    }

    final maxExtent = position.maxScrollExtent;
    if (maxExtent <= 0) return const SizedBox.shrink();

    final content = position.viewportDimension + maxExtent;
    final thumbLength =
        (position.viewportDimension / content * trackHeight * widget.thumbScale)
            .clamp(widget.minThumbLength, trackHeight);
    final progress = position.pixels.clamp(0.0, maxExtent) / maxExtent;
    final thumbTop = progress * (trackHeight - thumbLength);

    final radius = BorderRadius.circular(widget.thickness);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.trackColor,
              borderRadius: radius,
            ),
          ),
        ),
        Positioned(
          top: thumbTop,
          left: 0,
          right: 0,
          height: thumbLength,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.thumbColor.withValues(alpha: 0.62),
                  widget.thumbColor.withValues(alpha: 0.38),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
