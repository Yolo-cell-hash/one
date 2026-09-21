import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _brand = Color(0xFF810055);
const _defaultBorder = Color(0xFF8DFC63);
const _captionColor = Color(0xFF6B6B6B);
const _radius = 25.0;

/// A card at least this wide lays its media out as a side panel instead of
/// tucking it into a corner. Roughly "wider than half a phone".
const _wideBreakpoint = 320.0;

/// How a [GlassyContainer] places its image.
enum GlassyMediaLayout {
  /// Panel for wide cards, overlay for narrow ones.
  auto,

  /// Image sits inside the card behind the text, hugging a corner.
  overlay,

  /// Image becomes a rounded panel filling one side of the card, with the text
  /// column beside it. This is the "Entrance Camera" treatment.
  panel,
}

/// A single entry in the [GlassyContainer] bottom bar.
///
/// Use [BottomBarItem.icon] for a Flutter [IconData] (Material, Cupertino or a
/// custom icon font), or [BottomBarItem.asset] for an SVG / raster asset. The
/// asset constructor picks the right renderer from the file extension, so
/// `images/svgs/spaces.svg` is drawn with `flutter_svg` while a `.png` falls
/// back to [Image.asset].
class BottomBarItem {
  const BottomBarItem._({
    this.iconData,
    this.assetPath,
    this.package = 'godrej_one_sdk',
    this.color,
    this.size,
    this.tooltip,
    this.onTap,
  });

  /// An item backed by an [IconData], e.g. `Icons.home_filled`.
  const BottomBarItem.icon(
    IconData icon, {
    Color? color,
    double? size,
    String? tooltip,
    VoidCallback? onTap,
  }) : this._(
         iconData: icon,
         color: color,
         size: size,
         tooltip: tooltip,
         onTap: onTap,
       );

  /// An item backed by an asset. `.svg` files are rendered with
  /// [SvgPicture.asset]; anything else with [Image.asset].
  ///
  /// [package] defaults to `godrej_one_sdk` (assets shipped with this SDK);
  /// pass `null` for an asset that lives in the host app.
  const BottomBarItem.asset(
    String assetPath, {
    String? package = 'godrej_one_sdk',
    Color? color,
    double? size,
    String? tooltip,
    VoidCallback? onTap,
  }) : this._(
         assetPath: assetPath,
         package: package,
         color: color,
         size: size,
         tooltip: tooltip,
         onTap: onTap,
       );

  final IconData? iconData;
  final String? assetPath;
  final String? package;

  /// Tint for the item. Falls back to the bar's icon color.
  final Color? color;

  /// Overrides the bar's default icon size.
  final double? size;

  final String? tooltip;
  final VoidCallback? onTap;

  bool get isSvg =>
      assetPath != null && assetPath!.toLowerCase().endsWith('.svg');
}

class GlassyContainer extends StatelessWidget {
  const GlassyContainer({
    super.key,
    this.height,
    this.width,
    this.flex,
    this.title,
    this.subtitle,
    this.caption,
    this.subtitleIcon,
    this.subtitleIconColor,
    this.statusDotColor,
    this.sparkline,
    this.sparklineColor = _defaultBorder,
    this.borderExists = false,
    this.borderColor = _defaultBorder,
    this.imageExists = false,
    this.imagePath,
    this.imagePackage = 'godrej_one_sdk',
    this.imageAlignment = Alignment.bottomRight,
    this.imageWidthFactor = 0.6,
    this.imageHeightFactor = 0.7,
    this.imagePadding = EdgeInsets.zero,
    this.mediaLayout = GlassyMediaLayout.auto,
    this.mediaWidthFactor = 0.55,
    this.mediaOverlay,
    this.child,
    this.color = _brand,
    this.subtitleColor,
    @Deprecated('Use subtitleColor instead') this.subtitle_color,
    this.padding,
    this.onTap,
    this.isABottomBar = false,
    @Deprecated('Use isABottomBar instead') this.is_a_bottom_bar,
    this.bottomBarItems = const [],
    this.bottomBarIconSize,
    this.bottomBarIconColor = _brand,
    this.bottomBarSelectedIndex,
    this.bottomBarSelectedIconColor = Colors.white,
    this.bottomBarSelectedPillColor = const Color(0x8C9E9E9E),
  });

  final double? height;
  final double? width;
  final int? flex;

  final String? title;

  /// The big value line, e.g. `24.6 kWh` or `LOCKED`.
  final String? subtitle;

  /// The small line under the value, e.g. `Today`, `Cozy`, `Good`.
  final String? caption;

  /// Optional glyph rendered before [subtitle], e.g. a padlock.
  final IconData? subtitleIcon;
  final Color? subtitleIconColor;

  /// When set, a small filled dot is drawn at the bottom of the text column —
  /// the online/offline pip used by device tiles.
  final Color? statusDotColor;

  /// Sample values for the mini area chart drawn along the bottom of the card.
  /// Needs at least two points to render.
  final List<double>? sparkline;
  final Color sparklineColor;

  final bool borderExists;
  final Color borderColor;

  final bool imageExists;
  final String? imagePath;
  final String? imagePackage;

  /// Corner the image hugs in [GlassyMediaLayout.overlay].
  final Alignment imageAlignment;
  final double imageWidthFactor;
  final double imageHeightFactor;

  /// Inset for the overlay image. Leave at zero to let it bleed to the card
  /// edge (the door-lock look).
  final EdgeInsets imagePadding;

  final GlassyMediaLayout mediaLayout;

  /// Share of the card width taken by the media panel in
  /// [GlassyMediaLayout.panel].
  final double mediaWidthFactor;

  /// Drawn on top of the media panel, e.g. a recording badge.
  final Widget? mediaOverlay;

  /// Replaces the built-in title/subtitle/media layout with arbitrary
  /// content, while keeping the glass background, border and padding. Use
  /// this for one-off cards (empty states, custom forms) that still want the
  /// same glass treatment as the rest of the SDK.
  final Widget? child;

  final Color color;
  final Color? subtitleColor;
  @Deprecated('Use subtitleColor instead')
  final Color? subtitle_color;

  /// Overrides the responsive default content padding.
  final EdgeInsets? padding;

  final VoidCallback? onTap;

  final bool isABottomBar;
  @Deprecated('Use isABottomBar instead')
  final bool? is_a_bottom_bar;

  /// Items rendered inside the bottom bar. Each one is either an [IconData]
  /// ([BottomBarItem.icon]) or an SVG / image asset ([BottomBarItem.asset]).
  final List<BottomBarItem> bottomBarItems;

  /// Default size for every bottom bar item. Defaults to a share of the bar
  /// height so the bar scales with the screen.
  final double? bottomBarIconSize;

  /// Default tint for every bottom bar item that does not override it.
  final Color bottomBarIconColor;

  /// Index of the highlighted item, drawn inside a pill.
  final int? bottomBarSelectedIndex;
  final Color bottomBarSelectedIconColor;
  final Color bottomBarSelectedPillColor;

  bool get _hasMedia => imageExists && imagePath != null;

  // --------------------------------------------------------------- typography

  // Type is keyed off the screen width rather than the card width, so a wide
  // card and a narrow one share the same scale.
  TextStyle _titleStyle(double s) => TextStyle(
    fontFamily: 'GEG',
    package: 'godrej_one_sdk',
    fontSize: (s * 0.037).clamp(13.0, 18.0),
    fontWeight: FontWeight.w400,
    height: 1.25,
    color: color,
  );

  TextStyle _subtitleStyle(double s, Color c) => TextStyle(
    fontFamily: 'GEG',
    package: 'godrej_one_sdk',
    fontSize: (s * 0.057).clamp(18.0, 26.0),
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: c,
  );

  TextStyle _captionStyle(double s) => TextStyle(
    fontFamily: 'GEG',
    package: 'godrej_one_sdk',
    fontSize: (s * 0.029).clamp(10.0, 13.5),
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: _captionColor,
  );

  // --------------------------------------------------------------- bottom bar

  Widget _buildBottomBarItem(
    BottomBarItem item, {
    required bool selected,
    required double barIconSize,
  }) {
    final size = item.size ?? bottomBarIconSize ?? barIconSize;
    final tint =
        item.color ??
        (selected ? bottomBarSelectedIconColor : bottomBarIconColor);

    Widget child;
    final asset = item.assetPath;

    if (item.iconData != null) {
      child = Icon(item.iconData, size: size, color: tint);
    } else if (asset == null) {
      child = SizedBox(width: size, height: size);
    } else if (item.isSvg) {
      child = SvgPicture.asset(
        asset,
        package: item.package,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      );
    } else {
      child = Image.asset(
        asset,
        package: item.package,
        width: size,
        height: size,
        fit: BoxFit.contain,
        color: item.color ?? (selected ? tint : null),
      );
    }

    if (selected) {
      child = Container(
        padding: EdgeInsets.symmetric(
          horizontal: size * 0.72,
          vertical: size * 0.4,
        ),
        decoration: BoxDecoration(
          color: bottomBarSelectedPillColor,
          borderRadius: BorderRadius.circular(_radius * 0.8),
        ),
        child: child,
      );
    }

    if (item.tooltip != null) {
      child = Tooltip(message: item.tooltip!, child: child);
    }

    if (item.onTap != null) {
      child = InkResponse(onTap: item.onTap, radius: size * 1.4, child: child);
    }

    return child;
  }

  Widget _buildBottomBar() {
    final barHeight = height ?? 80;
    final iconSize = (barHeight * 0.32).clamp(20.0, 30.0);

    return SizedBox(
      height: barHeight,
      width: width ?? double.infinity,
      child: _glass(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: barHeight * 0.1),
          child: Row(
            children: [
              for (var i = 0; i < bottomBarItems.length; i++)
                Expanded(
                  child: Center(
                    child: _buildBottomBarItem(
                      bottomBarItems[i],
                      selected: i == bottomBarSelectedIndex,
                      barIconSize: iconSize,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------- glass

  Widget _glass({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(
                color: borderExists
                    ? borderColor
                    : Colors.white.withValues(alpha: 0.65),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ content

  Widget _textColumn(double s, {required bool bounded}) {
    final effectiveSubtitleColor = subtitleColor ?? subtitle_color ?? color;
    final hasValueBlock =
        subtitle != null || caption != null || statusDotColor != null;

    return Column(
      mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: _titleStyle(s),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        if (hasValueBlock)
          bounded ? const Spacer() : SizedBox(height: s * 0.03),
        if (subtitle != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (subtitleIcon != null) ...[
                Icon(
                  subtitleIcon,
                  size: (s * 0.046).clamp(15.0, 21.0),
                  color: subtitleIconColor ?? effectiveSubtitleColor,
                ),
                SizedBox(width: s * 0.014),
              ],
              Flexible(
                child: Text(
                  subtitle!,
                  style: _subtitleStyle(s, effectiveSubtitleColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              caption!,
              style: _captionStyle(s),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (statusDotColor != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              width: (s * 0.023).clamp(8.0, 11.0),
              height: (s * 0.023).clamp(8.0, 11.0),
              decoration: BoxDecoration(
                color: statusDotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _image({BoxFit fit = BoxFit.contain}) {
    return Image.asset(
      imagePath!,
      package: imagePackage,
      fit: fit,
      alignment: imageAlignment,
    );
  }

  Widget _mediaPanel(double w) {
    final inset = (w * 0.03).clamp(8.0, 14.0);
    return Padding(
      padding: EdgeInsets.all(inset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius - 8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _image(fit: BoxFit.cover),
            if (mediaOverlay != null) mediaOverlay!,
          ],
        ),
      ),
    );
  }

  EdgeInsets _contentPadding(double s) =>
      padding ?? EdgeInsets.all((s * 0.042).clamp(14.0, 20.0));

  Widget _buildCard(BuildContext context, BoxConstraints constraints) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final w = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : screenWidth;
    final bounded = constraints.maxHeight.isFinite;

    final customChild = child;
    if (customChild != null) {
      return Padding(padding: _contentPadding(screenWidth), child: customChild);
    }

    final layout = mediaLayout == GlassyMediaLayout.auto
        ? (_hasMedia && w >= _wideBreakpoint
              ? GlassyMediaLayout.panel
              : GlassyMediaLayout.overlay)
        : mediaLayout;

    if (_hasMedia && layout == GlassyMediaLayout.panel) {
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: _contentPadding(screenWidth),
              child: _textColumn(screenWidth, bounded: bounded),
            ),
          ),
          SizedBox(width: w * mediaWidthFactor, child: _mediaPanel(w)),
        ],
      );
    }

    final samples = sparkline;

    return Stack(
      children: [
        if (samples != null && samples.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: bounded ? constraints.maxHeight * 0.30 : 48,
            child: CustomPaint(
              painter: _SparklinePainter(samples, sparklineColor),
            ),
          ),
        if (_hasMedia)
          Positioned.fill(
            child: Padding(
              padding: imagePadding,
              child: Align(
                alignment: imageAlignment,
                child: FractionallySizedBox(
                  widthFactor: imageWidthFactor,
                  heightFactor: imageHeightFactor,
                  child: _image(),
                ),
              ),
            ),
          ),
        Padding(
          padding: _contentPadding(screenWidth),
          child: _textColumn(screenWidth, bounded: bounded),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBottomBar = is_a_bottom_bar ?? isABottomBar;

    if (isBottomBar) return _buildBottomBar();

    Widget card = SizedBox(
      height: height,
      width: flex == null ? width : null,
      child: _glass(child: LayoutBuilder(builder: _buildCard)),
    );

    if (onTap != null) {
      card = GestureDetector(onTap: onTap, child: card);
    }

    return flex == null ? card : Expanded(flex: flex!, child: card);
  }
}

/// Smooth area chart used by the energy tile.
class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0 || size.height <= 0) return;

    var min = values.first;
    var max = values.first;
    for (final v in values) {
      if (v < min) min = v;
      if (v > max) max = v;
    }
    final range = (max - min).abs() < 0.0001 ? 1.0 : max - min;

    final dx = size.width / (values.length - 1);
    // Keep the curve in the lower part of the band so it reads as a baseline.
    final top = size.height * 0.18;
    final usable = size.height - top - 2;

    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(i * dx, top + usable - ((values[i] - min) / range) * usable),
    ];

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final mid = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      line.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
    }
    line.lineTo(points.last.dx, points.last.dy);

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.55),
            color.withValues(alpha: 0.05),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
