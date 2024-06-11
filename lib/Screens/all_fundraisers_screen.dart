import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_nav_bar.dart';
import 'FundraiserMembersContributionScreen.dart';
import 'InvitedContributionScreen.dart';

class FundraisersScreen extends StatefulWidget {
  const FundraisersScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FundraisersScreenState createState() => _FundraisersScreenState();
}

class _FundraisersScreenState extends State<FundraisersScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> fundraisers = [];

  @override
  void initState() {
    super.initState();
    setupRealTimeUpdates();
  }

  Future<void> setupRealTimeUpdates() async {
    final pref = await SharedPreferences.getInstance();
    final phoneNo = pref.getString('phoneNo');
    if (phoneNo == null) return;

    final standardizedPhoneNo = '+$phoneNo'; // Adjusting the phone number format

    // Query for fundraisers created by the user
    db.collection('Fundraiser')
      .where('fund_created_by_phone', isEqualTo: standardizedPhoneNo)
      .where('status', isEqualTo: 0)
      .orderBy('fund_date_created', descending: true)
      .snapshots()
      .listen((snapshot) {
        processDocumentChanges(snapshot, true);
      });

    // Query for fundraisers where the user is invited
    db.collectionGroup('Fundraiser_Members')
      .where('phoneNo', isEqualTo: standardizedPhoneNo)
      .where('accepted_invite', isEqualTo: '0')
      .where('status', isEqualTo: 0)
      .snapshots()
      .listen((snapshot) {
        processDocumentChanges(snapshot, false);
      });
  }

  void processDocumentChanges(QuerySnapshot snapshot, bool isCreatedByUser) {
    setState(() {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var doc = change.doc;
          var data = doc.data() as Map<String, dynamic>;
          fundraisers.add({
            'title': data['fundraiser_name'] ?? 'No title',
            'description': data['fundraiser_desc'] ?? 'No description',
            'amount': data['target_amount']?.toString() ?? '0',
            'image': 'assets/images/default_avatar.svg', // Assuming a default image asset
            'isCreatedByUser': isCreatedByUser,
            'fundraiser': data,
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Fundraiser Cubes', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'All the fundraisers you have created or you are part of and have been invited to join will appear below.',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: fundraisers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 9),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Image.asset(
                      fundraisers[index]['image'],
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                    title: Text(
                      fundraisers[index]['title'],
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Target: ${fundraisers[index]['amount']}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                    onTap: () {
                      var fundraiser = fundraisers[index]['fundraiser'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => fundraisers[index]['isCreatedByUser']
                              ? FundraiserMembersContribution(fundraiser: fundraiser)
                              : InvitedContributionScreen(fundraiser: fundraiser),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 3, // Make sure this index corresponds to the correct tab for 'Fundraisers'
        onItemSelected: (index) {
          // Implement your navigation logic here, based on index
          // For example, index 0 could switch to the home screen, etc.
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FundraisersScreen(),
  ));
}
