import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class AdminUsersView extends StatelessWidget {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.adminUsers)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'بحث بالاسم أو الإيميل',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          SoftCard(
            child: Column(
              children: [
                _RowUser('سارة أ.', 'مفعّل', AppColors.statusActive),
                const Divider(),
                _RowUser('محمد ح.', 'موقوف', AppColors.statusInactive),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () {},
                child: const Text('إيقاف'),
              ),
              FilledButton.tonal(
                onPressed: () {},
                child: const Text('تفعيل'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () {},
                child: const Text('حذف'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RowUser extends StatelessWidget {
  const _RowUser(this.name, this.status, this.c);
  final String name;
  final String status;
  final Color c;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status, style: TextStyle(color: c, fontSize: 12)),
        ),
      ],
    );
  }
}
