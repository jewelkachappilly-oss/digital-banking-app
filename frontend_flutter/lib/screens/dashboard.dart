import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/colors.dart';
import '../widgets/beneficiary_card.dart';
import '../widgets/service_tile.dart';
import 'login.dart';
import 'pay_screen.dart';
import 'transactions.dart';

class _Service {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Service(this.icon, this.label, this.onTap);
}

class Dashboard extends StatefulWidget {
  final Map<String, dynamic> user;
  const Dashboard({super.key, required this.user});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Map<String, dynamic> user = Map<String, dynamic>.from(widget.user);
  int tab = 0;
  int get userId => user['user_id'];

  Future<void> refresh() async {
    final p = await Api.profile(userId);
    if (mounted) setState(() => user = p);
  }

  void comingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title feature added as demo UI')));
  }

  Future<void> openPay({String? upi}) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => PayScreen(userId: userId, initialUpi: upi)));
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [home(), banking(), Transactions(userId: userId, embedded: true), profile()];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        indicatorColor: AppColors.red.withOpacity(.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.account_balance_outlined), selectedIcon: Icon(Icons.account_balance), label: 'Banking'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget home() {
    final balance = (user['balance'] as num).toDouble();
    final services = <_Service>[
      _Service(Icons.outbox_rounded, 'Send money', () => openPay()),
      _Service(Icons.signal_cellular_alt_rounded, 'Buy airtime', () => comingSoon('Buy airtime')),
      _Service(Icons.wifi_rounded, 'Buy data', () => comingSoon('Buy data')),
      _Service(Icons.electric_bolt_outlined, 'Electricity', () => comingSoon('Electricity bill')),
      _Service(Icons.receipt_long_outlined, 'Pay bills', () => comingSoon('Pay bills')),
      _Service(Icons.currency_exchange, 'Foreign curr.', () => comingSoon('Foreign currency')),
      _Service(Icons.shopping_bag_outlined, 'Lifestyle', () => comingSoon('Lifestyle')),
      _Service(Icons.grid_view_rounded, 'More', () => comingSoon('More services')),
    ];
    final beneficiaries = [
      ('Rahul', 'rahul5112@bank', Icons.person),
      ('Anu', 'anu5112@bank', Icons.face_3),
      ('Kevin', 'kevin5112@bank', Icons.face),
      ('Mariya', 'mariya5112@bank', Icons.face_4),
    ];

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundColor: AppColors.red.withOpacity(.10), child: const Icon(Icons.person, color: AppColors.red)),
              const SizedBox(width: 12),
              Expanded(child: Text('Hello,\n${user['name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.15))),
              IconButton(onPressed: () => comingSoon('Notifications'), icon: const Icon(Icons.notifications_none_rounded)),
              IconButton(onPressed: refresh, icon: const Icon(Icons.qr_code_scanner_rounded)),
              Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('N', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            height: 172,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(colors: [AppColors.redDark, AppColors.red], begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: AppColors.red.withOpacity(.20), blurRadius: 24, offset: const Offset(0, 12))],
            ),
            child: Stack(children: [
              Positioned(right: -18, bottom: -18, child: Icon(Icons.account_balance, size: 118, color: Colors.white.withOpacity(.10))),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text('${user['upi']}'.replaceAll('@bank', ''), style: const TextStyle(color: Colors.white, letterSpacing: 5, fontSize: 16)), const SizedBox(width: 8), const Icon(Icons.copy, color: Colors.white, size: 18)]),
                const Spacer(),
                Row(children: const [Text('Savings Account', style: TextStyle(color: Colors.white, fontSize: 14)), SizedBox(width: 8), Icon(Icons.visibility_outlined, color: Colors.white, size: 18)]),
                const SizedBox(height: 8),
                Text('₹${balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
              ]),
              Positioned(right: 0, top: 0, child: IconButton(onPressed: refresh, icon: const Icon(Icons.north_east, color: Colors.white))),
            ]),
          ),
          const SizedBox(height: 26),
          const Text('Top services', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 14, crossAxisSpacing: 12, childAspectRatio: .78),
            itemBuilder: (_, i) => ServiceTile(icon: services[i].icon, label: services[i].label, onTap: services[i].onTap),
          ),
          const SizedBox(height: 22),
          RichText(text: const TextSpan(style: TextStyle(color: AppColors.text, fontSize: 18), children: [TextSpan(text: 'Quick transfer ', style: TextStyle(fontWeight: FontWeight.w900)), TextSpan(text: '- Beneficiary') ])),
          const SizedBox(height: 12),
          SizedBox(
            height: 98,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: beneficiaries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => BeneficiaryCard(name: beneficiaries[i].$1, upi: beneficiaries[i].$2, icon: beneficiaries[i].$3, onTap: () => openPay(upi: beneficiaries[i].$2)),
            ),
          ),
          const SizedBox(height: 24),
          Row(children: [const Expanded(child: Text('Recent transactions', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))), TextButton(onPressed: () => setState(() => tab = 2), child: const Text('See all  →'))]),
          recentTransactions(),
        ],
      ),
    );
  }

  Widget recentTransactions() {
    return FutureBuilder<List<dynamic>>(
      future: Api.transactions(userId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Card(child: Padding(padding: EdgeInsets.all(18), child: Center(child: CircularProgressIndicator())));
        final list = (snap.data ?? []).take(3).toList();
        if (list.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No recent transactions yet')));
        return Column(children: list.map((e) {
          final tx = e as Map<String, dynamic>;
          final sent = tx['type'] == 'sent';
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: (sent ? AppColors.red : AppColors.green).withOpacity(.12), child: Icon(sent ? Icons.arrow_upward : Icons.arrow_downward, color: sent ? AppColors.red : AppColors.green)),
              title: Text(tx['party_name'], style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(tx['party_upi']),
              trailing: Text('${sent ? '-' : '+'}₹${(tx['amount'] as num).toStringAsFixed(2)}', style: TextStyle(color: sent ? AppColors.red : AppColors.green, fontWeight: FontWeight.w900)),
            ),
          );
        }).toList());
      },
    );
  }

  Widget banking() => ListView(padding: const EdgeInsets.all(18), children: [
    const Text('Banking', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    const SizedBox(height: 14),
    _bankTile(Icons.account_balance_wallet_outlined, 'Accounts', 'Savings balance and UPI ID'),
    _bankTile(Icons.credit_card, 'Cards', 'Debit card demo controls'),
    _bankTile(Icons.security, 'Security', 'PIN, OTP and device safety'),
    _bankTile(Icons.support_agent, 'Support', 'College project help desk'),
  ]);

  Widget _bankTile(IconData icon, String title, String sub) => Card(child: ListTile(leading: Icon(icon, color: AppColors.red), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(sub), trailing: const Icon(Icons.chevron_right)));

  Widget profile() => ListView(padding: const EdgeInsets.all(18), children: [
    const SizedBox(height: 10),
    CircleAvatar(radius: 42, backgroundColor: AppColors.red.withOpacity(.10), child: const Icon(Icons.person, color: AppColors.red, size: 42)),
    const SizedBox(height: 14),
    Center(child: Text(user['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
    Center(child: Text(user['email'], style: const TextStyle(color: AppColors.muted))),
    const SizedBox(height: 20),
    _bankTile(Icons.alternate_email, 'UPI ID', user['upi']),
    _bankTile(Icons.verified_user_outlined, 'Account status', 'Demo verified'),
    const SizedBox(height: 18),
    ElevatedButton.icon(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false), icon: const Icon(Icons.logout), label: const Text('Logout')),
  ]);
}
