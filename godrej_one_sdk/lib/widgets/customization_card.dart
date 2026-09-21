import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomizationCard extends StatefulWidget {
  const CustomizationCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.card_icon,
    this.cardImage,
    this.cardImagePackage = 'godrej_one_sdk',
    required this.hasIcon,
  });

  final String title;
  final String subtitle;
  final IconData? card_icon;
  final String? cardImage;
  final String? cardImagePackage;
  final bool hasIcon;

  @override
  State<CustomizationCard> createState() => _CustomizationCardState();
}

class _CustomizationCardState extends State<CustomizationCard> {
  static const _brand = Color(0xFF810055);

  @override
  Widget build(BuildContext context) {
    Widget leading;
    if (widget.cardImage != null && widget.cardImage!.isNotEmpty) {
      final asset = widget.cardImage!;
      if (asset.toLowerCase().endsWith('.svg')) {
        leading = SvgPicture.asset(
          asset,
          package: widget.cardImagePackage,
          width: 24.0,
          height: 24.0,
          fit: BoxFit.contain,
          color: _brand,
        );
      } else {
        leading = Image.asset(
          asset,
          package: widget.cardImagePackage,
          width: 24.0,
          height: 24.0,
          fit: BoxFit.contain,
        );
      }
    } else if (widget.card_icon != null && widget.hasIcon) {
      leading = Icon(widget.card_icon, color: _brand, size: 24.0);
    } else {
      leading = const SizedBox(width: 24.0, height: 24.0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leading,
              const SizedBox(width: 20.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: "GEG",
                      package: 'godrej_one_sdk',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: "GEG",
                      package: 'godrej_one_sdk',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            margin: const EdgeInsets.only(left: 20.0),
            child: const Text(
              'Add',
              style: TextStyle(
                fontSize: 19,
                color: _brand,
                fontFamily: "GEG",
                package: 'godrej_one_sdk',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}