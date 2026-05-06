import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/colors.dart';
import 'success.dart';

class OtpPin extends StatefulWidget {
  final int userId;
  final String upi;
  final double amount;
  const OtpPin({super.key, required this.userId, required this.upi, required this.amount});
  @override
  State<OtpPin> createState() => _OtpPinState();
}

class _OtpPinState extends State<OtpPin> {
  final otp = TextEditingController();
  final pin = TextEditingController();
  bool loading = false;
  String? error;
  String? devOtp;

  @override
  void initState() {
    super.initState();
    Api.sendOtp(widget.userId).then((res) {
      if (mounted) setState(() => devOtp = res['dev_otp']?.toString());
    }).catchError((e) {
      if (mounted) setState(() => error = e.toString());
    });
  }

  Future<void> pay() async {
    setState(() { loading = true; error = null; });
    try {
      final res = await Api.pay(widget.userId, widget.upi, widget.amount, pin.text, otp.text);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Success(balance: (res['balance'] as num).toDouble())));
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Payment')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pay ₹${widget.amount.toStringAsFixed(2)} to', style: const TextStyle(fontSize: 16)),
          Text(widget.upi, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navy)),
          const SizedBox(height: 20),
          if (devOtp != null) Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.gold.withOpacity(.25), borderRadius: BorderRadius.circular(16)), child: Text('Demo OTP: $devOtp')),
          const SizedBox(height: 14),
          TextField(controller: otp, decoration: const InputDecoration(labelText: 'OTP', prefixIcon: Icon(Icons.sms)), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: pin, decoration: const InputDecoration(labelText: 'UPI PIN', prefixIcon: Icon(Icons.pin)), obscureText: true, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          if (error != null) Text(error!, style: const TextStyle(color: AppColors.red)),
          const Spacer(),
          ElevatedButton(onPressed: loading ? null : pay, child: loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Pay Now')),
        ]),
      ),
    );
  }
}
