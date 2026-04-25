import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class MyDeliveriesView extends StatelessWidget {
  const MyDeliveriesView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Connect to backend API for fetching accepted deliveries
    final mockDeliveries = [
      {
        'id': '1023',
        'status': 'جاري الاستلام',
        'pickup': 'صيدلية العزبي - شارع التحرير',
        'dropoff': 'شارع السودان - المهندسين',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('توصيلاتي الحالية'),
      ),
      body: mockDeliveries.isEmpty
          ? const Center(
              child: Text(
                'لا يوجد لديك طلبات نشطة حالياً.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockDeliveries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final delivery = mockDeliveries[index];
                return SoftCard(
                  onTap: () {
                    context.push('/delivery/details/${delivery['id']}');
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'طلب #${delivery['id']}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.statusPending.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              delivery['status']!,
                              style: const TextStyle(color: AppColors.statusPending, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.storefront, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              delivery['pickup']!,
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              delivery['dropoff']!,
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
