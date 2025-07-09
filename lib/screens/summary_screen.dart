import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 80, color: Color(0xFFA855F7)),
          SizedBox(height: 20),
          Text(
            'Summary Screen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'View your analytics and summary here.',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
