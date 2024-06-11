import 'package:flutter/material.dart';
import 'package:nisave/widgets/menu_card.dart';
import 'package:nisave/widgets/bottom_nav_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nisave/navigation/route_paths.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _fullName = 'Loading...'; // Placeholder for user's full name
  String _walletBalance = 'Loading...'; // Placeholder for wallet balance

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _checkInternetConnection();
    FirebaseMessaging.instance.subscribeToTopic("myTopic");
  }

  Future<void> _loadUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _fullName = prefs.getString('firstName') ?? 'Unknown';
      _fullName += " ${prefs.getString('lastName') ?? 'User'}";
      _walletBalance = prefs.getString('walletBalance') ?? '0';
    });
  }

  void _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('You are not connected to the internet. Some features may not be available.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
        title: const Text('Nisave', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Welcome, $_fullName', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KES $_walletBalance',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          '4242 **** **** ****',
                          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8, left: 16),
                    child: Text(
                      'Wallet Balance',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8),
              child: Text('My Home', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: const EdgeInsets.all(16.0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                MenuCard(
                  title: 'Borrow Peer to Peer Loan',
                  icon: Icons.swap_horiz,
                  onTap: () {},
                ),
                MenuCard(
                  title: 'Create a Cube',
                  icon: Icons.dashboard,
                  onTap: () {},
                ),
                MenuCard(
                  title: 'Start a Fundraiser',
                  icon: Icons.favorite,
                  onTap: () {
                    Navigator.pushNamed(context, RoutePaths.createFundraiserCube);
                  },
                ),
                MenuCard(
                  title: 'Manage my Wallet',
                  icon: Icons.account_balance_wallet,
                  onTap: () {},
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.black),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can reach us via email through info@nisave.com',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onItemSelected: (index) {},
      ),
    );
  }
}
