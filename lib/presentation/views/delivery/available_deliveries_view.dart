import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class AvailableDeliveriesView extends StatelessWidget {
  const AvailableDeliveriesView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Connect to backend API for fetching available deliveries
    final mockDeliveries = [
      {
        'id': '1042',
        'distance': '1.2 كم',
        'pickup': 'مطعم الشيف حسن - المهندسين',
        'dropoff': 'شارع جامعة الدول - المهندسين',
        'price': '35 جنيه',
        'time': 'منذ 5 دقائق',
      },
      {
        'id': '1045',
        'distance': '3.4 كم',
        'pickup': 'مغسلة الأمل - الدقي',
        'dropoff': 'شارع التحرير - الدقي',
        'price': '25 جنيه',
        'time': 'منذ 12 دقيقة',
      },
    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text('الطلبات المتاحة'),
      ),
      body: ListView.separated(
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        delivery['distance']!,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _LocationRow(icon: Icons.storefront, text: delivery['pickup']!, isPickup: true),
                const Padding(
                  padding: EdgeInsets.only(right: 9, top: 4, bottom: 4),
                  child: Icon(Icons.more_vert, size: 16, color: AppColors.textHint),
                ),
                _LocationRow(icon: Icons.location_on, text: delivery['dropoff']!, isPickup: false),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      delivery['time']!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    Text(
                      delivery['price']!,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 15),
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

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.icon, required this.text, required this.isPickup});
  final IconData icon;
  final String text;
  final bool isPickup;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isPickup ? AppColors.textSecondary : AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
