// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'dart:async';
import 'package:chat_app/src/Initials/onboarding_page.dart';
import 'package:chat_app/src/Initials/sign_in_page.dart';
import 'package:chat_app/src/helper/globals.dart';
import 'package:chat_app/src/pages/tab_bar.dart';
import 'package:chat_app/src/services/storage.service.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double sWidth = 0;
  double bWidth = 0;
  double sHeight = 0;
  double bHeight = 0;
  double iconHeight = 0;

  @override
  void initState() {
    // StorageService.logout();
    super.initState();
    Timer(const Duration(milliseconds: 100), () {
      timer();
      timer2();
      goNext();
    });
  }

  timer2() {
    Timer(const Duration(microseconds: 500), () {
      iconHeight = 150;
      if (mounted) setState(() {});
    });
  }

  timer() {
    Timer(const Duration(milliseconds: 1100), () {
      sWidth = 140;
      sHeight = 140;
      if (mounted) setState(() {});
      Timer(const Duration(milliseconds: 200), () {
        bWidth = 220;
        bHeight = 220;
        if (mounted) setState(() {});
      });
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnboardingPage()),
    );
  }

  Future<void> _checkOnboarding() async {
    String? isOnboardingShown =
        await StorageService.getString('onboarding_shown');
    if (isOnboardingShown == null) {
      _navigateToOnboarding();
    } else if (isOnboardingShown == 'YES') {
      _navigateToLogin();
    }
  }

  goNext() async {
    Timer(const Duration(milliseconds: 3000), () {
      StorageService.getLogin().then((user) {
        if (user == false) {
          // Navigator.of(context).pushAndRemoveUntil(
          //     MaterialPageRoute(builder: (context) => SignInScreen()),
          //     (Route<dynamic> route) => false);
          _checkOnboarding();
        } else {
          StorageService.getString("appwallpaper").then((wallpaper) {
            if (mounted) setState(() => appwallpaper = wallpaper);
          });
          if (mounted) setState(() => userSD = user);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const TabsUserScreen()),
              (Route<dynamic> route) => false);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: lightColor,
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeIn,
                    height: sHeight,
                    width: sWidth,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(250),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeIn,
                    height: bHeight,
                    width: bWidth,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(800),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeIn,
                  height: iconHeight,
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/native_splash.png',
                      width: 280,
                      height: 280,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeIn,
                      height: sHeight,
                      width: sWidth,
                      decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(250))),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeIn,
                      height: bHeight,
                      width: bWidth,
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(800))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
