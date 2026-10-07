import 'package:flutter/material.dart';

/// Avatar, "Hey, name!" and a one-line subtitle, with [trailing] actions on
/// the right — the top of the photo-backed pages (My Spaces and each
/// space's own page).
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.name,
    required this.asset,
    required this.subtitle,
    required this.trailing,
  });

  final String name;

  /// Avatar image.
  final String asset;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    final avatar = (w * 0.11).clamp(38.0, 48.0); // Responsive avatar sizing

    return Padding(
      padding: EdgeInsets.only(
        top: media.padding.top + 12.0,
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              asset,
              package: 'godrej_one_sdk',
              width: avatar,
              height: avatar,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hey, $name!',
                  style: TextStyle(
                    fontSize: (w * 0.055).clamp(18.0, 24.0),
                    fontFamily: 'GEG',
                    package: 'godrej_one_sdk',
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: (w * 0.035).clamp(12.0, 15.0),
                    fontFamily: 'GEG',
                    package: 'godrej_one_sdk',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
