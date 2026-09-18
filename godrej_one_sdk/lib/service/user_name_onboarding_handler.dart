/// A resident of the home, with the photo shown on the landing page.
class OnboardingUser {
  const OnboardingUser({required this.name, required this.image});

  final String name;
  final String image;
}

class UserNameOnboardingHandler {
  static const List<OnboardingUser> users = [
    OnboardingUser(name: 'Riya', image: 'images/pfp1.png'),
    OnboardingUser(name: 'Jason', image: 'images/pfp2.png'),
    OnboardingUser(name: 'Sasha', image: 'images/pfp3.png'),
  ];
}
