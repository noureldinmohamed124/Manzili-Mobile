import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class AdminOrdersView extends StatelessWidget {
  const AdminOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final mockOrders = [
      {'id': '1046', 'buyer': 'أحمد (عميل)', 'seller': 'محمود (سباك)', 'status': 'مكتمل'},
      {'id': '1047', 'buyer': 'سارة (عميل)', 'seller': 'غير محدد', 'status': 'مرفوض'},
    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text('إدارة الطلبات'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockOrders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = mockOrders[index];
          return SoftCard(
            onTap: () => context.push('/admin/orders/details/${order['id']}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'طلب #${order['id']}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: order['status'] == 'مكتمل'
                              ? AppColors.statusActive.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order['status']!,
                          style: TextStyle(
                            color: order['status'] == 'مكتمل' ? AppColors.statusActive : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('العميل: ${order['buyer']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('المزود: ${order['seller']}', style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
