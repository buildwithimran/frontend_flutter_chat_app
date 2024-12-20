class OnboardingContent {
  final String image;
  final String title;
  final String description;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<OnboardingContent> contents = [
  OnboardingContent(
    image: 'assets/images/image1.svg',
    title: 'Welcome to TeamPro',
    description: 'This is an awesome app!',
  ),
  OnboardingContent(
    image: 'assets/images/image2.svg',
    title: 'Explore Features',
    description: 'Discover the amazing features of our app!',
  ),
  OnboardingContent(
    image: 'assets/images/image3.svg',
    title: 'Get Started',
    description: 'Let\'s get started and enjoy the app!',
  ),
];
