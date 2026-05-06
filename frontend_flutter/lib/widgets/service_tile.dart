import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ServiceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const ServiceTile({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.035), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Center(child: Icon(icon, color: AppColors.red, size: 31)),
          ),
          const SizedBox(height: 8),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
