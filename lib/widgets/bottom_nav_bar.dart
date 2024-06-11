import 'package:flutter/material.dart';
import 'package:nisave/navigation/route_paths.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomNavBar({super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      unselectedItemColor: Colors.black,
      selectedItemColor: const Color(0xFFEA0753),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view),
          label: 'Cubes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz),
          label: 'P2P Loans',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Fundraisers',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: (index) {
        onItemSelected(index);
        switch (index) {
          case 0: // Home tab index
            Navigator.pushReplacementNamed(context, RoutePaths.home);
            break;
          case 3: // Fundraisers tab index
            Navigator.pushNamedAndRemoveUntil(context, RoutePaths.fundraisers, ModalRoute.withName('/'));
            break;
          // Add cases for other tabs if needed
        }
      },
    );
  }
}
