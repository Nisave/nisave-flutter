import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nisave/widgets/CustomButton.dart';
import 'package:nisave/navigation/route_paths.dart';


class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _phoneController = TextEditingController();

  ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>Navigator.pushReplacementNamed(context, RoutePaths.login),
        ),
        title: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Enter your phone number below to receive a password reset code.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18, // Increased font size
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24), // Adjusted spacing
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    'assets/images/flags.svg', // Replace with your flag icon path
                    width: 24,
                    height: 24,
                  ),
                ),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16), // Reduced spacing for a tighter layout
            CustomButton(
              text: 'Send Code',
              onPressed: () {
                // Implement send code logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
