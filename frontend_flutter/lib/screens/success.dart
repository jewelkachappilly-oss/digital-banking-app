import 'package:flutter/material.dart';
import '../theme/colors.dart';

class Success extends StatelessWidget {
  final double balance;
  const Success({super.key, required this.balance});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.check_circle, color: AppColors.green, size: 110),
            const SizedBox(height: 18),
            const Text('Payment Successful', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 8),
            Text('New balance: ₹${balance.toStringAsFixed(2)}'),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), child: const Text('Back to Dashboard')),
          ]),
        ),
      ),
    );
  }
}
