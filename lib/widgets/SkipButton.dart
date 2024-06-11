import 'package:flutter/material.dart';

class SkipButton extends StatelessWidget {
  final VoidCallback onSkip;

  const SkipButton({super.key, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // Handle back action, for example, pop the context from the navigation stack
            },
          ),
          GestureDetector(
            onTap: onSkip,
            child: const Text(
              'SKIP',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 16,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
