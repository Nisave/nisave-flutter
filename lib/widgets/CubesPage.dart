import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart'; // Make sure to add the flutter_svg package in your pubspec.yaml
import 'package:nisave/widgets/SkipButton.dart'; // Make sure this import statement is correct
import 'package:nisave/navigation/route_paths.dart';

class CubesPage extends StatelessWidget {
  const CubesPage({super.key});

  void _handleSkip(BuildContext context) {
    // Define what happens when you skip
    // For example, navigate to another screen
        Navigator.pushNamed(context, RoutePaths.register_landing);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
           SkipButton(
              onSkip: () => _handleSkip(context),
            ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0),
                child: SvgPicture.asset('assets/images/Illustration2.svg'),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 80.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cubes',
                  style: TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 22,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 30.0),
                  child: Text(
                    'Create your cube where you can borrow or lend.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF222222),
                      fontSize: 16,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      );
  }
}
