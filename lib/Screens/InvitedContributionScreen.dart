// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nisave/widgets/CustomButton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'contributors.dart';

class InvitedContributionScreen extends StatefulWidget {
  final Map<String, dynamic> fundraiser;

  const InvitedContributionScreen({super.key, required this.fundraiser});

  @override
  _InvitedContributionScreenState createState() => _InvitedContributionScreenState();
}

class _InvitedContributionScreenState extends State<InvitedContributionScreen> {
  late String title;
  late String image;
  late String organizer;
  late String phone;
  late String dateCreated;
  late String goal;
  late String amountRaised;
  late String description;
  late double percentage;
  List<Map<String, dynamic>> members = [];

  @override
  void initState() {
    super.initState();
    initializeData();
    fetchMembersData();
  }

  void initializeData() {
    title = widget.fundraiser['fundraiser_name'] ?? 'No title';
    image = 'assets/images/default_avatar.svg';
    organizer = widget.fundraiser['fund_created_by_name'] ?? widget.fundraiser['created_by_name'] ?? 'Unknown organizer';
    phone = widget.fundraiser['fund_created_by_phone'] ?? widget.fundraiser['created_by_phone'] ?? 'Unknown phone';
    dateCreated = formatDate(widget.fundraiser['fund_date_created'] ?? widget.fundraiser['date_created']);
    goal = widget.fundraiser['target_amount']?.toString() ?? '0';
    amountRaised = widget.fundraiser['amount_raised']?.toString() ?? '0';
    description = widget.fundraiser['fundraiser_desc'] ?? 'No description';

    double goalAmount = double.tryParse(goal) ?? 0.0;
    double raisedAmount = double.tryParse(amountRaised) ?? 0.0;
    percentage = goalAmount > 0 ? (raisedAmount / goalAmount) * 100 : 0.0;
  }

  void fetchMembersData() {
    FirebaseFirestore.instance
        .collection('Fundraiser')
        .doc(widget.fundraiser['fundraiser_id'])
        .collection('Fundraiser_Members')
        .where('accepted_invite', isEqualTo: '0')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        members = querySnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'name': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
            'amount_contributed': data['amount_contributed_by_member']?.toString() ?? '0',
          };
        }).toList();
      });
    });
  }

  String formatDate(dynamic date) {
    try {
      if (date is Timestamp) {
        DateTime dateTime = date.toDate();
        return DateFormat('dd MMM yyyy').format(dateTime);
      } else if (date is String) {
        DateTime dateTime = DateFormat('MMM dd, yyyy').parse(date);
        return DateFormat('dd MMM yyyy').format(dateTime);
      } else {
        return 'Unknown date';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  void showContributionDialog(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final contributorPhoneNumber = pref.getString('phoneNo') ?? '';
    final formattedPhone = contributorPhoneNumber.replaceAll(RegExp(r'\s+'), '');

    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$title Contribution'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the amount you would like to contribute:'),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Amount',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = amountController.text;
                debugPrint('Amount entered: $amount');
                if (amount.isNotEmpty) {
                  final validAmount = int.tryParse(amount) ?? 0;
                  debugPrint('Valid amount: $validAmount');
                  if (validAmount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('The amount is not valid')),
                    );
                  } else {
                    final fundraiserIdStk = 'FUN-${widget.fundraiser['fundraiser_id']}';
                    final accessToken = pref.getString('accessToken') ?? '';

                    final requestBody = jsonEncode({
                      'Amount': validAmount.toString(),
                      'PhoneNumber': formattedPhone,
                      'AccountReference': fundraiserIdStk,
                    });

                    debugPrint('Request body: $requestBody');

                    try {
                      final response = await ApiService().sendSTKPushRequest(accessToken, requestBody);
                      debugPrint('Request sent with status code: ${response.statusCode} and body: ${response.body}');
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('You will be directed to make this payment')),
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to process payment: ${response.body}')),
                        );
                        debugPrint('Failed to process payment: ${response.statusCode} ${response.body}');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                      debugPrint('Error: $e');
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an amount.')),
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Add more functionality as needed
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(image),
              ),
              title: Text(organizer, style: const TextStyle(color: Colors.black, fontSize: 20)),
              subtitle: Text(phone, style: const TextStyle(color: Colors.black, fontSize: 16)),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDetailRow('Created', dateCreated),
                  buildDetailRow('Goal', 'KES $goal'),
                  buildDetailRow('Amount Raised', 'KES $amountRaised'),
                  buildPercentageRow('${percentage.toStringAsFixed(2)}%'),
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  Text(description, style: const TextStyle(color: Colors.black)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllContributionsScreen1(fundraiserId: widget.fundraiser['fundraiser_id']),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contributions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'See members',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CustomButton(
                      onPressed: () {
                        showContributionDialog(context);
                      },
                      text: 'Contribute',
                    ),
                  ),
                  const Divider(),
                  ...members.map((member) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(member['name'], style: const TextStyle(color: Colors.black)),
                          Text('Contributed: KES ${member['amount_contributed']}', style: const TextStyle(color: Colors.black)),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(value, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget buildPercentageRow(String percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Percentage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(percentage, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
