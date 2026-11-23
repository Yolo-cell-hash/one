/// A resident of the home: how the app addresses them, their contact
/// details, and their photo (an asset path or a file on the device).
class OnboardingUser {
  const OnboardingUser({
    required this.name,
    required this.fullName,
    required this.image,
    this.code = '+91',
    this.mobile = '',
    this.email = '',
  });

  /// In-app name — "Hey, Riya!", "Welcome home Riya".
  final String name;

  /// Full name — the landing header card and Profile.
  final String fullName;
  final String image;

  /// Country calling code, e.g. "+91".
  final String code;
  final String mobile;
  final String email;

  OnboardingUser copyWith({
    String? name,
    String? fullName,
    String? image,
    String? code,
    String? mobile,
    String? email,
  }) => OnboardingUser(
    name: name ?? this.name,
    fullName: fullName ?? this.fullName,
    image: image ?? this.image,
    code: code ?? this.code,
    mobile: mobile ?? this.mobile,
    email: email ?? this.email,
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'fullName': fullName,
    'image': image,
    'code': code,
    'mobile': mobile,
    'email': email,
  };

  factory OnboardingUser.fromJson(Map<String, Object?> json) => OnboardingUser(
    name: json['name']! as String,
    fullName: json['fullName']! as String,
    image: json['image']! as String,
    code: json['code'] as String? ?? '+91',
    mobile: json['mobile'] as String? ?? '',
    email: json['email'] as String? ?? '',
  );
}

class UserNameOnboardingHandler {
  static const List<OnboardingUser> users = [
    OnboardingUser(
      name: 'Riya',
      fullName: 'Riya Malhotra',
      image: 'images/pfp1.png',
    ),
    OnboardingUser(
      name: 'Jason',
      fullName: 'Jason Malhotra',
      image: 'images/pfp2.png',
    ),
    OnboardingUser(
      name: 'Sasha',
      fullName: 'Sasha Malhotra',
      image: 'images/pfp3.png',
    ),
  ];
}
