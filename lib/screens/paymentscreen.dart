import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.payment, size: 80, color: Color(0xFFA855F7)),
          SizedBox(height: 20),
          Text(
            'Payment Screen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Manage your payments here.', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
