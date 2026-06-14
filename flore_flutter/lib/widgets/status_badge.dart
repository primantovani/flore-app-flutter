import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Color _color() {
    switch (status.toLowerCase()) {
      case 'em trânsito': return const Color(0xFFd4541a);
      case 'entregue':    return const Color(0xFF2a7d70);
      case 'no armazém':  return const Color(0xFF3d9e8f);
      default:            return const Color(0xFF6b6b6b);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color().withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: _color().withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(color: _color(), fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
