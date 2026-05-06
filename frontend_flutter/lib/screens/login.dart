import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/colors.dart';
import 'dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final pin = TextEditingController(text: '1234');
  bool loading = false;
  bool signup = false;
  String? error;

  Future<void> submit() async {
    setState(() { loading = true; error = null; });
    try {
      final res = signup ? await Api.register(name.text, email.text, pass.text, pin.text) : await Api.login(email.text, pass.text);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Dashboard(user: res)));
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 36),
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.account_balance, color: AppColors.gold, size: 34)),
            const SizedBox(height: 20),
            Text(signup ? 'Create your account' : 'Welcome back', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.navy)),
            const SizedBox(height: 6),
            const Text('Secure mobile banking demo connected to Django API.'),
            const SizedBox(height: 26),
            if (signup) TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person))),
            if (signup) const SizedBox(height: 12),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            TextField(controller: pass, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)), obscureText: true),
            if (signup) const SizedBox(height: 12),
            if (signup) TextField(controller: pin, decoration: const InputDecoration(labelText: 'UPI PIN', prefixIcon: Icon(Icons.pin)), obscureText: true, keyboardType: TextInputType.number),
            const SizedBox(height: 14),
            if (error != null) Text(error!, style: const TextStyle(color: AppColors.red)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: loading ? null : submit, child: loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(signup ? 'Register' : 'Login')),
            TextButton(onPressed: () => setState(() { signup = !signup; error = null; }), child: Text(signup ? 'Already have account? Login' : 'New user? Create account')),
            const SizedBox(height: 12),
            const Text('Tip: Create two accounts to test money transfer. Default UPI PIN is 1234.', style: TextStyle(fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}
