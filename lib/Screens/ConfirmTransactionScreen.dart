import 'package:flutter/material.dart';
import 'package:nisave/Screens/OTPVerificationScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConfirmTransactionScreen extends StatefulWidget {
  final String transactionType;
  final String phoneNumber;
  final String? tillNumber;
  final String? paybillNumber;
  final String? accountNumber;
  final String amount;
  final String fundraiserId;

  const ConfirmTransactionScreen({
    Key? key,
    required this.transactionType,
    required this.phoneNumber,
    this.tillNumber,
    this.paybillNumber,
    this.accountNumber,
    required this.amount,
    required this.fundraiserId,
  }) : super(key: key);

  @override
  _ConfirmTransactionScreenState createState() => _ConfirmTransactionScreenState();
}

class _ConfirmTransactionScreenState extends State<ConfirmTransactionScreen> {
  late String accessToken;
  late String displayText;
  late double newAmount;

  @override
  void initState() {
    super.initState();
    _getAccessToken();
    _setDisplayText();
  }

  Future<void> _getAccessToken() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      accessToken = pref.getString('accessToken') ?? '';
    });
  }

  void _setDisplayText() {
    setState(() {
      double amount = double.parse(widget.amount);
      double fee = amount * 0.02;
      newAmount = amount - fee;

      switch (widget.transactionType) {
        case 'PAYBILL_NUMBER':
          displayText = 'You are about to transfer KES ${widget.amount} to paybill number ${widget.phoneNumber}, account number ${widget.accountNumber}. A 2% platform fee will be charged. The amount after fee deduction will be KES ${newAmount.toStringAsFixed(2)}.';
          break;
        case 'TILL_NUMBER':
          displayText = 'You are about to transfer KES ${widget.amount} to till number ${widget.phoneNumber}. A 2% platform fee will be charged. The amount after fee deduction will be KES ${newAmount.toStringAsFixed(2)}.';
          break;
        case 'OTHER_NUMBER':
          displayText = 'You are about to transfer KES ${widget.amount} to phone number ${widget.phoneNumber}. A 2% platform fee will be charged. The amount after fee deduction will be KES ${newAmount.toStringAsFixed(2)}.';
          break;
        case 'WITHDRAW_FUNDS':
          displayText = 'You are about to withdraw KES ${widget.amount} to phone number ${widget.phoneNumber}. A 2% platform fee will be charged. The amount after fee deduction will be KES ${newAmount.toStringAsFixed(2)}.';
          break;
        default:
          displayText = 'Invalid transaction type';
      }
    });
  }

  Future<void> _requestOtp() async {
    final response = await http.post(
      Uri.parse('http://payments.nisave.co.ke:8080/otp/request'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'JWT $accessToken',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You will receive an OTP. Please input it.')),
      );
      // Navigate to OTPVerificationScreen with the necessary data
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            transactionType: widget.transactionType,
            phoneNumber: widget.phoneNumber,
            tillNumber: widget.tillNumber,
            paybillNumber: widget.paybillNumber,
            accountNumber: widget.accountNumber,
            amount: widget.amount,
            fundraiserId: widget.fundraiserId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to request OTP: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayText, style: TextStyle(fontSize: 16)),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Decline'),
                ),
                ElevatedButton(
                  onPressed: _requestOtp,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
