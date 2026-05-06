import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبات'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (adminProvider.errorMessage != null) {
            return Center(
              child: Text(adminProvider.errorMessage!, style: const TextStyle(color: AppColors.error)),
            );
          }

          final orders = adminProvider.ordersResponse?.items ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('لا توجد طلبات'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              final isCompleted = order.currentStatus == 'Completed' || order.currentStatus == 'مكتمل';

              return SoftCard(
                onTap: () => context.push('/admin/orders/details/${order.orderId}'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'طلب #${order.orderId}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppColors.statusActive.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              order.currentStatus,
                              style: TextStyle(
                                color: isCompleted ? AppColors.statusActive : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('العميل: ${order.buyerName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('المزود: ${order.providerName}', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
