import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:small_pdf_maker_/view/constants/colors.dart';
import 'package:small_pdf_maker_/view/screens/bottomnavigation.dart';
import 'package:small_pdf_maker_/view/screens/onboardingscreen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _navigateToOnboarding() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Onboradingscreen()),
      (route) => false,
    );
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainHome()),
      (route) => false,
    );
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    final appBox = Hive.box('appBox');
    final isFirstTime = appBox.get('isFirstTime', defaultValue: true);

    if (!mounted) return;

    if (isFirstTime) {
      appBox.put('isFirstTime', false);
      _navigateToOnboarding();
    } else {
      _navigateToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Appcolors.secondaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/images/appIcon.png",
              height: size.height * 0.22,
              width: size.width * 0.4,
              // fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Light PDF Maker",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Appcolors.buttonColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Effortless PDF Creation Anytime, Anywhere",
            style: TextStyle(fontSize: 14, color: Appcolors.subHeadingColor),
          ),
        ],
      ),
    );
  }
}
