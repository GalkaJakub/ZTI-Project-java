import 'package:flutter/material.dart';

class InviteCodeBox extends StatelessWidget {
  const InviteCodeBox({
    super.key,
    required this.inviteCode,
    required this.onCopy,
  });

  final String inviteCode;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.vpn_key_outlined, color: Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kod zaproszenia',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  inviteCode,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Kopiuj kod',
            onPressed: onCopy,
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
    );
  }
}
