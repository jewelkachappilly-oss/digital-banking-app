import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/colors.dart';

class Transactions extends StatelessWidget {
  final int userId;
  final bool embedded;
  const Transactions({super.key, required this.userId, this.embedded = false});
  @override
  Widget build(BuildContext context) {
    final body = FutureBuilder<List<dynamic>>(
      future: Api.transactions(userId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text(snap.error.toString(), style: const TextStyle(color: AppColors.red)));
        final list = snap.data ?? [];
        if (list.isEmpty) return const Center(child: Text('No transactions yet'));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final tx = list[i] as Map<String, dynamic>;
            final sent = tx['type'] == 'sent';
            return Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: sent ? AppColors.red.withOpacity(.12) : AppColors.green.withOpacity(.12), child: Icon(sent ? Icons.arrow_upward : Icons.arrow_downward, color: sent ? AppColors.red : AppColors.green)),
                title: Text('${sent ? 'Sent to' : 'Received from'} ${tx['party_name']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${tx['party_upi']}\n${tx['created_at']}'),
                isThreeLine: true,
                trailing: Text('${sent ? '-' : '+'}₹${(tx['amount'] as num).toStringAsFixed(2)}', style: TextStyle(color: sent ? AppColors.red : AppColors.green, fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
    if (embedded) {
      return SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Padding(padding: EdgeInsets.all(18), child: Text('Transactions', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900))), Expanded(child: body)]));
    }
    return Scaffold(appBar: AppBar(title: const Text('Transactions')), body: body);
  }
}
