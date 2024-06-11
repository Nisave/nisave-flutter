import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nisave/widgets/SkipButton.dart'; // Make sure this import statement is correct
import 'package:nisave/navigation/route_paths.dart';

class LoansPage extends StatelessWidget {
  const LoansPage({super.key});

  void _handleSkip(BuildContext context) {
    // Navigate to the register screen using named routing
    Navigator.pushNamed(context, RoutePaths.register_landing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( // Wrap your column in a SafeArea widget to avoid overlaps with the status bar
        child: Column(
          children: [
            SkipButton(
              onSkip: () => _handleSkip(context),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36.0),
                  child: SvgPicture.asset('assets/images/Illustration.svg'),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 80.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Loans',
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
                      'Send and receive money from your friends and family.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 16,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
