import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class AdminServicesView extends StatelessWidget {
  const AdminServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final mockServices = [
      {
        'id': '201',
        'title': 'كحك وبسكوت العيد (سمن بلدي)',
        'provider': 'Abdo Sherif',
        'status': 'مراجعة',
      },
      {
        'id': '202',
        'title': 'خدمة كروشيه حسب المقاس (شيلان وملابس شتوي)',
        'provider': 'Mona Crochet',
        'status': 'معتمد',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة الخدمات'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockServices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final s = mockServices[index];
          final isPending = s['status'] == 'مراجعة';

          return SoftCard(
            onTap: () => context.push('/admin/services/details/${s['id']}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.design_services, color: AppColors.textHint),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['title']!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('بواسطة: ${s['provider']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending ? AppColors.statusPending.withValues(alpha: 0.1) : AppColors.statusActive.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s['status']!,
                      style: TextStyle(
                        color: isPending ? AppColors.statusPending : AppColors.statusActive,
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
