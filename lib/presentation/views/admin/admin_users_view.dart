import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class AdminUsersView extends StatelessWidget {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final mockUsers = [
      {'id': '101', 'name': 'أحمد محمود', 'role': 'عميل', 'status': 'نشط'},
      {'id': '102', 'name': 'شركة الأمل', 'role': 'مزود خدمة', 'status': 'موقوف'},
      {'id': '103', 'name': 'محمد حسن', 'role': 'مندوب توصيل', 'status': 'مراجعة'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockUsers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final u = mockUsers[index];
          final isActive = u['status'] == 'نشط';
          final isPending = u['status'] == 'مراجعة';

          return SoftCard(
            onTap: () => context.push('/admin/users/details/${u['id']}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u['name']!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(u['role']!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.statusActive.withValues(alpha: 0.1)
                          : isPending
                              ? AppColors.statusPending.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      u['status']!,
                      style: TextStyle(
                        color: isActive
                            ? AppColors.statusActive
                            : isPending
                                ? AppColors.statusPending
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
