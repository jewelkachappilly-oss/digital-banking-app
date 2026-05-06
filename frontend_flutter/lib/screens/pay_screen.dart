import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'otp_pin.dart';

class PayScreen extends StatefulWidget {
  final int userId;
  final String? initialUpi;
  const PayScreen({super.key, required this.userId, this.initialUpi});
  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  late final TextEditingController upi = TextEditingController(text: widget.initialUpi ?? '');
  final amount = TextEditingController();
  String? error;

  void next() {
    final amt = double.tryParse(amount.text);
    if (upi.text.trim().isEmpty || amt == null || amt <= 0) {
      setState(() => error = 'Enter valid receiver UPI and amount');
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => OtpPin(userId: widget.userId, upi: upi.text.trim(), amount: amt)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send money')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.red.withOpacity(.08), borderRadius: BorderRadius.circular(24)),
            child: const Row(children: [Icon(Icons.lock, color: AppColors.red), SizedBox(width: 12), Expanded(child: Text('Secure payment uses OTP + UPI PIN verification.'))]),
          ),
          const SizedBox(height: 20),
          const Text('Receiver details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 16),
          TextField(controller: upi, decoration: const InputDecoration(labelText: 'Receiver UPI ID', prefixIcon: Icon(Icons.alternate_email))),
          const SizedBox(height: 12),
          TextField(controller: amount, decoration: const InputDecoration(labelText: 'Amount', prefixIcon: Icon(Icons.currency_rupee)), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          if (error != null) Text(error!, style: const TextStyle(color: AppColors.red)),
          const SizedBox(height: 28),
          ElevatedButton(onPressed: next, child: const Text('Continue Securely')),
        ],
      ),
    );
  }
}
