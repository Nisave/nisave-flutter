import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nisave/navigation/route_paths.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateFundraiserScreen extends StatefulWidget {
  const CreateFundraiserScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateFundraiserScreenState createState() => _CreateFundraiserScreenState();
}

class _CreateFundraiserScreenState extends State<CreateFundraiserScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _fundraiserTopicController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Fundraiser Cube', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What is a Fundraiser Cube?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            const Text(
              'This is a special cube that allows you to raise funds and track fundraiser progress. Create your fundraiser cube and invite people to join.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _fundraiserTopicController,
              decoration: const InputDecoration(
                labelText: 'Fundraiser Topic',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDatePickerField(_startDateController, 'Start Date', selectStartDate),
            const SizedBox(height: 24),
            _buildDatePickerField(_endDateController, 'End Date', selectEndDate),
            const SizedBox(height: 24),
            TextField(
              controller: _targetAmountController,
              decoration: const InputDecoration(
                labelText: 'Amount you target to collect (KES)',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Fundraiser Description',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                onPressed: _createFundraiser,
                child: const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField(TextEditingController controller, String label, Function() onTap) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      readOnly: true,
      onTap: onTap,
    );
  }

  Future<void> selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _createFundraiser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String firstName = prefs.getString('firstName') ?? 'First';
    String lastName = prefs.getString('lastName') ?? 'Last';
    String phoneNumber = prefs.getString('phoneNo') ?? 'No phone number';

    String fundName = _fundraiserTopicController.text;
    String startDate = _startDateController.text;
    String endDate = _endDateController.text;
    String description = _descriptionController.text;
    int targetAmount = int.tryParse(_targetAmountController.text) ?? 0;

    Map<String, dynamic> fundraiserData = {
      'fundraiser_name': fundName,
      'fund_date_created': startDate,
      'fundraiser_duration': endDate,
      'fundraiser_desc': description,
      'target_amount': targetAmount,
      'fund_created_by_name': '$firstName $lastName',
      'fund_created_by_phone': phoneNumber,
      'amount_raised': 0,  // Initialize amount_raised as 0
      'status': 0,  // Initialize status as 0
    };

    DocumentReference docRef = await db.collection('fundraisers').add(fundraiserData);

    // Update the document with its own ID
    await docRef.update({
      'fundraiser_id': docRef.id
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fundraiser created successfully with ID: ${docRef.id}')));
          Navigator.pushNamedAndRemoveUntil(context, RoutePaths.fundraisers, ModalRoute.withName('/'));

    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating fundraiser with ID: $error')));
    });
  }
}
