import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const MenuCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
   Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
      margin: const EdgeInsets.all(10.0),
      elevation: 4, // Add elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Change to a circular border radius
      ),
      color: Colors.white,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Inner padding for the card
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use the minimum space
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.black), // Icon size and color
              const SizedBox(height: 8), // Space between icon and text
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
