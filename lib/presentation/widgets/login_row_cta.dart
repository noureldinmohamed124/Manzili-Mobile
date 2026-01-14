// ========================= login_row_cta.dart =========================
import 'package:flutter/material.dart';

class LoginRowCTA extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const LoginRowCTA({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48, // ✅ bigger
            height: 48, // ✅ bigger
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF8D28),
                  Color(0xFFC20AFA),
                ],
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24, // ✅ bigger
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 20, // ✅ bigger
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
