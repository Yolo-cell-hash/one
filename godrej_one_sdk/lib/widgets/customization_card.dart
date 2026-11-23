import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/providers/bottom_bar_provider.dart';
import 'package:godrej_one_sdk/service/show_elegant_toast.dart';

/// One feature on the Navigation page: its glyph, name and a one-line
/// description, with a grey "Add" pill — "Added" once it's in the bar.
class CustomizationCard extends StatelessWidget {
  const CustomizationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.id,
    this.icon,
    this.cardImage,
  });

  final String title;
  final String subtitle;

  /// The feature's id in [BottomBarProvider].
  final String id;

  /// The glyph: an [IconData], or an SVG / image asset in [cardImage].
  final IconData? icon;
  final String? cardImage;

  static const _brand = Color(0xFF810055);

  Widget _leading() {
    final asset = cardImage;
    if (asset == null) return Icon(icon, color: _brand, size: 26);
    if (asset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        asset,
        package: 'godrej_one_sdk',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(_brand, BlendMode.srcIn),
      );
    }
    return Image.asset(asset, package: 'godrej_one_sdk', width: 24, height: 24);
  }

  @override
  Widget build(BuildContext context) {
    // A card's own id is checked against the bar's live item list —
    // BottomBarProvider is the single source of truth for what's actually
    // in the bar (see bottom_bar_provider.dart), so this never drifts from
    // what the bottom bar itself shows.
    final isAdded = context.select<BottomBarProvider, bool>(
      (bar) => bar.indexOfId(id) != null,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 4.5, 34, 4.5),
      child: Row(
        children: [
          SizedBox(width: 26, child: Center(child: _leading())),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'GEG',
                    package: 'godrej_one_sdk',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A8A8A),
                    fontFamily: 'GEG',
                    package: 'godrej_one_sdk',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            button: true,
            label: isAdded ? '$title added' : 'Add $title',
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => showElegantToast(
                context,
                isAdded ? 'Already added' : 'Coming soon',
              ),
              child: Container(
                width: 82,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCDCDC),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Text(
                  isAdded ? 'Added' : 'Add',
                  style: const TextStyle(
                    fontSize: 16,
                    color: _brand,
                    fontFamily: 'GEG',
                    package: 'godrej_one_sdk',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
