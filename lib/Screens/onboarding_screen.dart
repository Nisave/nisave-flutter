// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:nisave/widgets/CreditRatingsPage.dart';
import 'package:nisave/widgets/CubesPage.dart';
import 'package:nisave/widgets/LoansPage.dart';
import 'package:nisave/state/app_state.dart';
import 'package:nisave/navigation/route_paths.dart';
import 'package:nisave/widgets/CustomButton.dart'; // Correct the path to your CustomButton widget


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

   @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  void _completeOnboarding(BuildContext context) {
    AppState().completeOnboarding();
    Navigator.pushReplacementNamed(context, RoutePaths.register_landing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const LoansPage(),
              const CubesPage(),
              const CreditRatingsPage(),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                );
              }),
            ),
          ),
          if (_currentPage == 2) // Assuming this is the last page
            // Replace ElevatedButton with CustomButton
    Positioned(
        bottom: 60, // Increase this value to push the button lower
        left: 0,
        right: 0,
          child: Center(
            child: CustomButton(
              text: 'Get Started',
              onPressed: () => _completeOnboarding(context),
      // Your CustomButton may have additional properties that need to be included here.
    ),
  ),
),

        ],
      ),
    );
  }
}
