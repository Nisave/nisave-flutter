import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nisave/widgets/CustomButton.dart';
import 'package:nisave/navigation/route_paths.dart';

class LoginLand extends StatelessWidget {
  const  LoginLand({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the size of the screen for responsive layout
    Size screenSize = MediaQuery.of(context).size;

    // Calculate the space above and below the middle image
    double topSpace = screenSize.height * 0.1;
    double bottomSpace = screenSize.height * 0.1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Adjust the size and positioning of the top corner image
              Align(
                alignment: Alignment.topRight,
                child: SvgPicture.asset(
                  'assets/images/corner.svg', // Make sure this path is correct
                  width: screenSize.width * 0.5, // Adjust the width to 50% of the screen width
                ),
              ),
              SizedBox(height: topSpace),

              // Middle image with reduced size
              SvgPicture.asset(
                'assets/images/middle.svg', // Make sure this path is correct
                width: screenSize.width * 0.4, // Adjust the width to 40% of the screen width
              ),
              SizedBox(height: screenSize.height * 0.05), // Space between the image and text

              // Main title text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 36.0),
                child: Text(
                  'Loans made easier',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Subtitle text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 16.0),
                child: Text(
                  'A friendly peer to peer lending platform that allows you to borrow from your cube and improve your credit rating on the app!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 16,
                  ),
                ),
              ),

              // Register button
              CustomButton(
                text: 'Log In',
                onPressed: () {
                  // Handle the Register button press
                  Navigator.pushReplacementNamed(context, RoutePaths.login);

                },
              ),

              // Log In button
              TextButton(
                onPressed: () {
                  // Handle the Log In button press
                  Navigator.pushReplacementNamed(context, RoutePaths.register);

                },
                child: const Text(
                  'Not registered? Register Here',
                  style: TextStyle(
                    color: Colors.black, // Color changed to black
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              SizedBox(height: bottomSpace),
            ],
          ),
        ),
      ),
    );
  }
}
