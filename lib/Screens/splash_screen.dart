// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nisave/state/app_state.dart';
import 'package:nisave/navigation/route_paths.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;


    // Calculate the scale factor for the text based on the screen width
    double textScaleFactor = screenWidth / 100; // Adjust the divisor to get the desired scale

    Future.delayed(const Duration(seconds: 2), () {
      if (AppState().hasCompletedOnboarding) {
        Navigator.pushReplacementNamed(context, RoutePaths.login_landing);
      } else {
        Navigator.pushReplacementNamed(context, RoutePaths.onboarding);
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/Group1.svg',
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.3,
                ),
                const SizedBox(height: 20),
                Text(
                  'nisave',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF383838),
                    fontSize: 24 * textScaleFactor, // Scale the font size
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
