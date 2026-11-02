import 'package:flutter/painting.dart';

/// A home the resident can switch between on the landing page.
class Property {
  const Property({
    required this.name,
    required this.locality,
    required this.thumbnail,
    required this.background,
  });

  /// City shown in the properties list.
  final String name;

  /// Neighbourhood shown under "Welcome home".
  final String locality;

  /// Photo shown in the properties list row.
  final String thumbnail;

  /// Full-bleed photo behind the landing page.
  final String background;

  ImageProvider get backgroundImage =>
      AssetImage(background, package: 'godrej_one_sdk');

  /// [background] decoded small: blurring it for the frosted look is cheap,
  /// and it can be faded in without blurring the live page behind it.
  ImageProvider get frostedImage => ResizeImage(backgroundImage, width: 96);

  /// [thumbnail] decoded at the size its row shows it, rather than at the
  /// full size of the photo.
  ImageProvider get thumbnailImage =>
      ResizeImage(AssetImage(thumbnail, package: 'godrej_one_sdk'), width: 420);

  static const all = [
    Property(
      name: 'Mumbai',
      locality: 'Malabar hills',
      thumbnail: 'images/properties/mumbai.png',
      background: 'images/landing_base_bg.png',
    ),
    Property(
      name: 'Chennai',
      locality: 'Besant Nagar',
      thumbnail: 'images/properties/chennai.jpg',
      background: 'images/properties/chennai.jpg',
    ),
    Property(
      name: 'Kochi',
      locality: 'Marine Drive',
      thumbnail: 'images/properties/kochi.webp',
      background: 'images/properties/kochi.webp',
    ),
  ];
}
