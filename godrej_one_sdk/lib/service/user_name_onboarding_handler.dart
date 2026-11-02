/// A resident of the home, with the photo shown on the landing page.
class OnboardingUser {
  const OnboardingUser({
    required this.name,
    required this.fullName,
    required this.image,
  });

  final String name;

  /// Shown on the landing page's header card.
  final String fullName;
  final String image;
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
