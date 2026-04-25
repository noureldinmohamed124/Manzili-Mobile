import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class SellerServicesListView extends StatelessWidget {
  const SellerServicesListView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Connect to backend API to fetch seller's own services
    final mockServices = [
      {'title': 'تنظيف مكيفات', 'price': '١٥٠ جنيه', 'status': 'نشط'},
      {'title': 'صيانة سباكة', 'price': 'يبدأ من ٥٠ جنيه', 'status': 'نشط'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('خدماتي'),
        actions: [
          IconButton(
            onPressed: () => context.push('/seller/create-service'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: mockServices.isEmpty
          ? const Center(
              child: Text(
                'ليس لديك أي خدمات حتى الآن.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockServices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final service = mockServices[index];
                return SoftCard(
                  onTap: () {
                    // Navigate to update service
                    context.push('/seller/edit-service');
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image, color: AppColors.textHint),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['title']!,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              service['price']!,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.statusActive.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                service['status']!,
                                style: const TextStyle(color: AppColors.statusActive, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_left, color: AppColors.textHint),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
