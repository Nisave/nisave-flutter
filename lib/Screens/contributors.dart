import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Contributor {
  final String name;
  final String phone;
  final double amountContributed;
  late final String imageUrl;

  Contributor({
    required this.name,
    required this.phone,
    required this.amountContributed,
    required this.imageUrl,
  });
}

class AllContributionsScreen1 extends StatefulWidget {
  final String fundraiserId;

  const AllContributionsScreen1({super.key, required this.fundraiserId});

  @override
  // ignore: library_private_types_in_public_api
  _AllContributionsScreenState createState() => _AllContributionsScreenState();
}

class _AllContributionsScreenState extends State<AllContributionsScreen1> {
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
          name: doc['name'] ?? 'Unknown Member',
          phone: doc['phone'] ?? '',
          amountContributed: (doc['amount_contributed'] ?? 0).toDouble(),
          imageUrl: doc['image_url'] ?? '',
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
              backgroundImage: contributor.imageUrl.isNotEmpty
                  ? NetworkImage(contributor.imageUrl)
                  : const AssetImage('assets/images/default_avatar.svg') as ImageProvider,
              onBackgroundImageError: (_, __) {
                setState(() {
                  contributor.imageUrl = 'assets/images/default_avatar.svg';
                });
              },
            ),
            title: Text(
              'KES ${contributor.amountContributed}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${contributor.name}, ${contributor.phone}'),
          );
        },
      ),
    );
  }
}
