import 'package:flutter/material.dart';
import '../theme/colors.dart';

class BeneficiaryCard extends StatelessWidget {
  final String name;
  final String upi;
  final IconData icon;
  final VoidCallback onTap;
  const BeneficiaryCard({super.key, required this.name, required this.upi, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 88,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            CircleAvatar(radius: 25, backgroundColor: AppColors.red.withOpacity(.10), child: Icon(icon, color: AppColors.red)),
            const SizedBox(height: 8),
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
