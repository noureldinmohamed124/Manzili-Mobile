import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/admin_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/gradient_app_bar.dart';
import 'package:provider/provider.dart';

class AdminOrderDetailsView extends StatelessWidget {
  const AdminOrderDetailsView({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GradientAppBar(title: 'طلب #$orderId'),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                final orders = adminProvider.ordersResponse?.items ?? [];
                final id = int.tryParse(orderId) ?? 0;
                final order = orders.where((o) => o.orderId == id).firstOrNull;

                if (order == null) {
                  return const Center(child: Text('الطلب غير موجود'));
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SoftCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('أطراف الطلب', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 16),
                            _buildRow('العميل', '${order.buyerName} (ID: ${order.buyerId})'),
                            const Divider(),
                            _buildRow('مزود الخدمة', '${order.providerName} (ID: ${order.providerId})'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SoftCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('تفاصيل الخدمة', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 16),
                            _buildRow('الخدمة', order.serviceTitle),
                            const Divider(),
                            _buildRow('المبلغ الإجمالي', '${order.totalPrice} جنيه', isHighlight: true),
                            const Divider(),
                            _buildRow('تاريخ الطلب', order.createdAt != null ? order.createdAt.toString().split('T')[0] : 'غير معروف'),
                            const Divider(),
                            _buildRow('حالة الطلب', order.currentStatus),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text('إجراءات الإدارة', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('غير مدعوم حالياً'))),
                      icon: const Icon(Icons.support_agent),
                      label: const Text('التواصل مع الأطراف'),
                      style: FilledButton.styleFrom(backgroundColor: Colors.blueGrey),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('غير مدعوم حالياً'))),
                      icon: const Icon(Icons.cancel),
                      label: const Text('إلغاء الطلب (إرجاع أموال)'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                color: isHighlight ? AppColors.primary : null,
                overflow: TextOverflow.ellipsis,
              ),
              softWrap: true,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
