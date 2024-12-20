import 'package:chat_app/src/Initials/sign_in_page.dart';
import 'package:chat_app/src/services/storage.service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/src/initials/onboarding_card.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static final PageController _pageController = PageController(initialPage: 0);
  late List<Widget> _onBoardingPages;

  Future<void> _navigateToTabs() async {
    await StorageService.setString('onboarding_shown', 'YES');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  void initState() {
    super.initState();

    _onBoardingPages = [
      OnboardingCard(
        image: "assets/images/onboarding_1.png",
        title: 'Welcome to ChatApp!',
        description: 'Connect with friends and family instantly on ChatApp.',
        buttonText: 'Next',
        onPressed: () {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
        },
      ),
      OnboardingCard(
        image: "assets/images/onboarding_2.png",
        title: 'Manage account Easily!',
        description: 'Easily organize and track your messages.',
        buttonText: 'Next',
        onPressed: () {
          _pageController.animateToPage(
            2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
        },
      ),
      OnboardingCard(
        image: "assets/images/onboarding_3.png",
        title: 'Learn Personally',
        description: 'Enjoy safe and private chats with your contacts.',
        buttonText: 'Done',
        onPressed: () async {
          await _navigateToTabs();
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 50.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                children: _onBoardingPages,
              ),
            ),
            SmoothPageIndicator(
              controller: _pageController,
              count: _onBoardingPages.length,
              effect: ExpandingDotsEffect(
                activeDotColor: primaryColor,
                dotColor: primaryLightColor,
                radius: 40,
                dotWidth: 12,
                dotHeight: 12,
              ),
              onDotClicked: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
