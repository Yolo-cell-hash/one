import 'package:flutter/painting.dart';

import 'package:godrej_one_sdk/models/photo.dart';

/// A home the resident can switch between on the landing page, and edit
/// from Profile › Manage Properties.
class Property {
  const Property({
    required this.name,
    required this.location,
    required this.photo,
    this.background,
  });

  /// "Shrishti", "204, Hiranandani".
  final String name;

  /// "Malabar hills, Mumbai" — neighbourhood first, then the city.
  final String location;

  /// The property's photo: its row in the lists, and the landing page
  /// behind it unless [background] says otherwise. An asset path or a file.
  final String photo;

  /// A separate full-bleed photo for the landing page, when the list photo
  /// isn't framed for a full screen.
  final String? background;

  /// The neighbourhood alone, shown under "Welcome home".
  String get locality => location.split(',').first.trim();

  ImageProvider get backgroundImage => photoImage(background ?? photo);

  /// [backgroundImage] decoded small: blurring it for the frosted look is
  /// cheap, and it can be faded in without blurring the live page behind it.
  ImageProvider get frostedImage => ResizeImage(backgroundImage, width: 96);

  /// [photo] decoded at the size its row shows it, rather than at the full
  /// size of the photo.
  ImageProvider get thumbnailImage =>
      ResizeImage(photoImage(photo), width: 420);

  /// A new [photo] also becomes the landing page's photo.
  Property copyWith({String? name, String? location, String? photo}) =>
      Property(
        name: name ?? this.name,
        location: location ?? this.location,
        photo: photo ?? this.photo,
        background: photo == null ? background : null,
      );

  Map<String, Object?> toJson() => {
    'name': name,
    'location': location,
    'photo': photo,
    'background': background,
  };

  factory Property.fromJson(Map<String, Object?> json) => Property(
    name: json['name']! as String,
    location: json['location']! as String,
    photo: json['photo']! as String,
    background: json['background'] as String?,
  );

  static const defaults = [
    Property(
      name: 'Shrishti',
      location: 'Malabar hills, Mumbai',
      photo: 'images/properties/mumbai.png',
      background: 'images/landing_base_bg.png',
    ),
    Property(
      name: '204, Hiranandani',
      location: 'Powai, Mumbai',
      photo: 'images/properties/chennai.jpg',
    ),
    Property(
      name: '1603, Vaibhav',
      location: 'Vikhroli, Mumbai',
      photo: 'images/properties/kochi.webp',
    ),
  ];
}
