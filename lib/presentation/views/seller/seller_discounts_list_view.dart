import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class SellerDiscountsListView extends StatelessWidget {
  const SellerDiscountsListView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Connect to API for fetching discounts
    final mockDiscounts = [
      {'code': 'SUMMER20', 'type': 'خصم 20%', 'status': 'نشط'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الخصومات والعروض'),
        actions: [
          IconButton(
            onPressed: () => context.push('/seller/discounts/new'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: mockDiscounts.isEmpty
          ? const Center(
              child: Text(
                'لا توجد عروض أو خصومات نشطة.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockDiscounts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final discount = mockDiscounts[index];
                return SoftCard(
                  onTap: () => context.push('/seller/discounts/new'), // reusing editor for update
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            discount['code']!,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 2),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            discount['type']!,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.statusActive.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          discount['status']!,
                          style: const TextStyle(color: AppColors.statusActive, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
