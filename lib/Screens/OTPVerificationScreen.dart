import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String transactionType;
  final String amount;
  final String fundraiserId;
  final String? tillNumber;
  final String? paybillNumber;
  final String? accountNumber;

  const OTPVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.transactionType,
    required this.amount,
    required this.fundraiserId,
    this.tillNumber,
    this.paybillNumber,
    this.accountNumber,
  }) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late int _secondsLeft;
  late bool _isResendAllowed;

  @override
  void initState() {
    super.initState();
    _secondsLeft = 60; // set the initial timer value
    _isResendAllowed = false;
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_secondsLeft == 0) {
        setState(() {
          _isResendAllowed = true;
        });
      } else {
        setState(() {
          _secondsLeft--;
        });
        _startTimer();
      }
    });
  }

  void _resendCode() {
    setState(() {
      _secondsLeft = 60;
      _isResendAllowed = false;
    });
    _startTimer();
    // Add the logic to resend the OTP code here.
  }

  void _verifyOTP(String otp) {
    // Add the logic to verify the OTP here.
    // This can involve calling an API to verify the OTP.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP Verified: $otp')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Enter verification code sent to your number',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            OtpTextField(
              numberOfFields: 4,
              borderColor: const Color(0xFF512DA8),
              showFieldAsBox: true,
              onCodeChanged: (String code) {},
              onSubmit: (String verificationCode) {
                _verifyOTP(verificationCode);
              },
            ),
            const SizedBox(height: 20),
            Text(
              'You have 00:${_secondsLeft.toString().padLeft(2, '0')} Sec left',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add the logic to verify and log in
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink, // background color
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Verify and Log In'),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _isResendAllowed ? _resendCode : null,
                child: Text(
                  'Resend Code',
                  style: TextStyle(
                    color: _isResendAllowed ? Colors.blue : Colors.grey,
                    fontSize: 16,
                    decoration: _isResendAllowed
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
