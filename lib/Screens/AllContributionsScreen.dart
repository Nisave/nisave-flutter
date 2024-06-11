import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Contributor {
  final String name;
  final String phone;
  final double amountContributed;
  final String imageUrl;

  Contributor({
    required this.name,
    required this.phone,
    required this.amountContributed,
    required this.imageUrl,
  });
}

class AllContributionsScreen extends StatefulWidget {
  final String fundraiserId;

  const AllContributionsScreen({super.key, required this.fundraiserId});

  @override
  // ignore: library_private_types_in_public_api
  _AllContributionsScreenState createState() => _AllContributionsScreenState();
}

class _AllContributionsScreenState extends State<AllContributionsScreen> {
  List<Contributor> contributors = [];

  @override
  void initState() {
    super.initState();
    fetchContributorsData();
  }

  void fetchContributorsData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Fundraiser')
        .doc(widget.fundraiserId)
        .collection('Fundraiser_Members')
        .get();

    setState(() {
      contributors = snapshot.docs.map((doc) {
        return Contributor(
          name: doc.data().containsKey('firstName') ? doc['firstName'] : 'Unknown Member',
          phone: doc.data().containsKey('phoneNo') ? doc['phoneNo'] : '',
          amountContributed: doc.data().containsKey('amount_contributed_by_member') ? (doc['amount_contributed_by_member'] ?? 0).toDouble() : 0.0,
          imageUrl: 'assets/images/default_avatar.svg',
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Contributions'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: contributors.length,
        itemBuilder: (context, index) {
          final contributor = contributors[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(contributor.imageUrl),
            ),
            title: Text('KES ${contributor.amountContributed}', style: const TextStyle(color: Colors.black, fontSize: 16)),
            subtitle: Text('${contributor.name}, ${contributor.phone}', style: const TextStyle(color: Colors.black)),
          );
        },
      ),
    );
  }
}
