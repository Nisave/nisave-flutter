// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:nisave/widgets/CustomButton.dart';
import 'package:provider/provider.dart';
import 'package:nisave/state/login_state.dart';
import 'package:nisave/navigation/route_paths.dart';

class LoginScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    _pinController.addListener(_onPinChanged);
  }

  void _onPhoneChanged() {
    if (_phoneController.text.isEmpty) {
      FocusScope.of(context).unfocus();
    }
  }

  void _onPinChanged() {
    if (_pinController.text.isEmpty) {
      FocusScope.of(context).unfocus();
    }
  }

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('07') && phoneNumber.length == 10) {
      return '254${phoneNumber.substring(1)}';
    } else if (phoneNumber.startsWith('+254') && phoneNumber.length == 13) {
      return '254${phoneNumber.substring(4)}';
    } else if (phoneNumber.startsWith('254') && phoneNumber.length == 12) {
      return phoneNumber;
    } else {
      throw const FormatException('Invalid phone number format');
    }
  }

  void _login() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Loading"),
              ],
            ),
          ),
        );
      },
    );

    try {
      String formattedPhoneNumber = _formatPhoneNumber(_phoneController.text);
      bool loginSuccess = await Provider.of<LoginState>(context, listen: false).login(formattedPhoneNumber, _pinController.text);

      Navigator.pop(context); // Dismiss dialog
      if (loginSuccess) {
        Navigator.pushReplacementNamed(context, RoutePaths.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login failed")));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            const Text('Welcome to Nisave', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Kindly Log In to proceed', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 48),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pinController,
              decoration: const InputDecoration(labelText: '4 digit PIN', border: OutlineInputBorder()),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            CustomButton(text: 'Log In', onPressed: _login),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, RoutePaths.register),
              child: const Text('Not registered? Register Here', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}
