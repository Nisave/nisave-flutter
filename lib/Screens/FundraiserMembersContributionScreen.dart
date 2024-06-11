import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AllContributionsScreen.dart';
import 'ConfirmTransactionScreen.dart';
import 'all_fundraisers_screen.dart';
import '../widgets/CustomButton.dart';
import '../services/api_service.dart';

class FundraiserMembersContribution extends StatefulWidget {
  final Map<String, dynamic> fundraiser;

  const FundraiserMembersContribution({super.key, required this.fundraiser});

  @override
  _FundraiserMembersContributionState createState() => _FundraiserMembersContributionState();
}

class _FundraiserMembersContributionState extends State<FundraiserMembersContribution> {
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
    image = 'assets/images/default_avatar.svg'; // Default image
    organizer = widget.fundraiser['fund_created_by_name'] ??
        widget.fundraiser['created_by_name'] ??
        'Unknown organizer';
    phone = widget.fundraiser['fund_created_by_phone'] ??
        widget.fundraiser['created_by_phone'] ??
        'Unknown phone';
    dateCreated = formatDate(widget.fundraiser['fund_date_created'] ??
        widget.fundraiser['date_created']);
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

  void showWithdrawToOtherNumberDialog() {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Withdraw To Other Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('A 2% platform fee will be charged for all withdrawals. Enter phone number below:'),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(hintText: 'Phone Number'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(hintText: 'Amount'),
                keyboardType: TextInputType.number,
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
              onPressed: () {
                final phoneNumber = phoneController.text;
                final amount = amountController.text;
                if (phoneNumber.isNotEmpty && amount.isNotEmpty) {
                  final formattedPhone = phoneNumber.startsWith('0')
                      ? '254${phoneNumber.substring(1)}'
                      : phoneNumber;
                  final validAmount = int.tryParse(amount) ?? 0;
                  if (validAmount > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfirmTransactionScreen(
                          transactionType: 'OTHER_NUMBER',
                          phoneNumber: formattedPhone,
                          amount: validAmount.toString(),
                          fundraiserId: widget.fundraiser['fundraiser_id'],
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('The amount is not valid')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter all details.')),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void showWithdrawToTillNoDialog() {
    final TextEditingController tillNumberController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Withdraw To Till Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('A 2% platform fee will be charged for all withdrawals. Enter till number below:'),
              TextField(
                controller: tillNumberController,
                decoration: const InputDecoration(hintText: 'Till Number'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(hintText: 'Amount'),
                keyboardType: TextInputType.number,
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
              onPressed: () {
                final tillNumber = tillNumberController.text;
                final amount = amountController.text;
                if (tillNumber.isNotEmpty && amount.isNotEmpty) {
                  final validAmount = int.tryParse(amount) ?? 0;
                  if (validAmount > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfirmTransactionScreen(
                          transactionType: 'TILL_NUMBER',
                          phoneNumber: tillNumber,
                          amount: validAmount.toString(),
                          fundraiserId: widget.fundraiser['fundraiser_id'],
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('The amount is not valid')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter all details.')),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void showWithdrawToPaybillNumberDialog() {
    final TextEditingController paybillNumberController = TextEditingController();
    final TextEditingController accountNumberController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Withdraw To Paybill Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('A 2% platform fee will be charged for all withdrawals.'),
              TextField(
                controller: paybillNumberController,
                decoration: const InputDecoration(hintText: 'Paybill Number'),
              ),
              TextField(
                controller: accountNumberController,
                decoration: const InputDecoration(hintText: 'Account Number'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(hintText: 'Amount'),
                keyboardType: TextInputType.number,
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
              onPressed: () {
                final paybillNumber = paybillNumberController.text;
                final accountNumber = accountNumberController.text;
                final amount = amountController.text;

                if (paybillNumber.isNotEmpty && accountNumber.isNotEmpty && amount.isNotEmpty) {
                  final validAmount = int.tryParse(amount) ?? 0;
                  if (validAmount > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfirmTransactionScreen(
                          transactionType: 'PAYBILL_NUMBER',
                          phoneNumber: paybillNumber,
                          accountNumber: accountNumber,
                          amount: validAmount.toString(),
                          fundraiserId: widget.fundraiser['fundraiser_id'],
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('The amount is not valid')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter all details.')),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void showWithdrawFundraiserFundsDialog() async {
    final pref = await SharedPreferences.getInstance();
    final contributorPhoneNumber = pref.getString('phoneNo') ?? '';
    final formattedPhone = '+${contributorPhoneNumber.replaceAll(RegExp(r'\s+'), '')}';

    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Withdraw to Mpesa Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('A 2% platform fee will be charged for all withdrawals.'),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(hintText: 'Amount'),
                keyboardType: TextInputType.number,
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
                if (amount.isNotEmpty) {
                  final validAmount = int.tryParse(amount) ?? 0;
                  if (validAmount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('The amount is not valid')),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfirmTransactionScreen(
                          transactionType: 'WITHDRAW_FUNDS',
                          phoneNumber: formattedPhone,
                          amount: validAmount.toString(),
                          fundraiserId: widget.fundraiser['fundraiser_id'],
                        ),
                      ),
                    );
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

  void deleteDocument() {
    FirebaseFirestore.instance.collection('Fundraiser').doc(widget.fundraiser['fundraiser_id'])
      .get()
      .then((documentSnapshot) {
        final amountRaised = documentSnapshot.get('amount_raised');
        if (amountRaised != null && amountRaised > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot delete fundraiser with contributions')),
          );
        } else {
          _deleteFundraiser();
        }
      })
      .catchError((error) {
        debugPrint('Error getting fundraiser document: $error');
      });
  }

  void _deleteFundraiser() {
    FirebaseFirestore.instance.collection('Fundraiser').doc(widget.fundraiser['fundraiser_id'])
      .update({'status': 1})
      .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fundraiser deleted successfully')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => FundraisersScreen()),
          (route) => false,
        );
      })
      .catchError((error) {
        debugPrint('Error deleting fundraiser: $error');
      });
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String result) {
              switch (result) {
                case 'Withdraw_to_other_number':
                  showWithdrawToOtherNumberDialog();
                  break;
                case 'Withdraw_to_till_number':
                  showWithdrawToTillNoDialog();
                  break;
                case 'Withdraw_to_Paybill_number':
                  showWithdrawToPaybillNumberDialog();
                  break;
                case 'withdraw_fundraiser_funds':
                  showWithdrawFundraiserFundsDialog();
                  break;
                case 'delete_item':
                  deleteDocument();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Withdraw_to_other_number',
                child: Text('Withdraw to Other Number'),
              ),
              const PopupMenuItem<String>(
                value: 'Withdraw_to_till_number',
                child: Text('Withdraw to Till Number'),
              ),
              const PopupMenuItem<String>(
                value: 'Withdraw_to_Paybill_number',
                child: Text('Withdraw to Paybill Number'),
              ),
              const PopupMenuItem<String>(
                value: 'withdraw_fundraiser_funds',
                child: Text('Withdraw Fundraiser Funds'),
              ),
              const PopupMenuItem<String>(
                value: 'delete_item',
                child: Text('Delete Fundraiser'),
              ),
            ],
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
              title: Text(organizer,
                  style: const TextStyle(color: Colors.black, fontSize: 20)),
              subtitle: Text(phone,
                  style: const TextStyle(color: Colors.black, fontSize: 16)),
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
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  Text(description, style: const TextStyle(color: Colors.black)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllContributionsScreen(
                              fundraiserId: widget.fundraiser['fundraiser_id']),
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
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.black),
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
                          Text(member['name'],
                              style: const TextStyle(color: Colors.black)),
                          Text('Contributed: KES ${member['amount_contributed']}',
                              style: const TextStyle(color: Colors.black)),
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
          Text(label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
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
          const Text('Percentage',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
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
