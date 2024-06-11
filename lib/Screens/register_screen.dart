// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:nisave/widgets/CustomButton.dart';
import 'package:nisave/navigation/route_paths.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:nisave/state/register_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _termsAccepted = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    setState(() {
      _token = token;
    });
  }

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('07') && phoneNumber.length == 10) {
      return '254${phoneNumber.substring(1)}';
    } else if (phoneNumber.startsWith('+254') && phoneNumber.length == 13) {
      return phoneNumber.substring(1); // Removes the '+' sign
    } else if (phoneNumber.startsWith('254') && phoneNumber.length == 12) {
      return phoneNumber;
    } else {
      throw const FormatException('Invalid phone number format');
    }
  }

  void _register() async {
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Unable to fetch notification token")));
      return;
    }
    try {
      String formattedPhoneNumber = _formatPhoneNumber(_phoneController.text);
      bool success = await Provider.of<RegisterState>(context, listen: false).register(
        formattedPhoneNumber,
        _firstNameController.text,
        _lastNameController.text,
        _pinController.text,
        _token!
      );
      if (success) {
        Navigator.pushReplacementNamed(context, RoutePaths.login);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _launchURL(String urlString) async {
    if (await canLaunch(urlString)) {
      await launch(urlString);
    } else {
      throw 'Could not launch $urlString';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            const Text(
              'Kindly fill in the details below',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: '4 digit PIN',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPinController,
              decoration: const InputDecoration(
                labelText: 'Retype 4 digit PIN',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: InkWell(
                onTap: () => _launchURL('https://nisave.co.ke/terms-conditions'),
                child: const Text(
                  'I agree to the terms and conditions',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
              ),
              value: _termsAccepted,
              onChanged: (bool? newValue) {
                setState(() {
                  _termsAccepted = newValue!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Register',
              onPressed: _termsAccepted ? _register : null,
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, RoutePaths.login);
                },
                child: const Text(
                  'Already have an account? Sign In',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
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
