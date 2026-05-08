import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/admin_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/gradient_app_bar.dart';
import 'package:provider/provider.dart';

class AdminTransactionDetailsView extends StatelessWidget {
  const AdminTransactionDetailsView({super.key, required this.transactionId});
  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GradientAppBar(title: 'تفاصيل TRX-$transactionId'),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                final financials = adminProvider.financialsResponse?.items ?? [];
                final id = int.tryParse(transactionId) ?? 0;
                final transaction = financials.where((t) => t.transactionId == id).firstOrNull;

                if (transaction == null) {
                  return const Center(child: Text('المعاملة غير موجودة'));
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
                            const Text('بيانات المعاملة', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 16),
                            _buildRow('تاريخ المعاملة', transaction.createdAt != null ? transaction.createdAt.toString().split('T')[0] : 'غير معروف'),
                            const Divider(),
                            _buildRow('الخدمة المرتبطة', transaction.serviceTitle),
                            const Divider(),
                            _buildRow('المبلغ', '${transaction.totalPrice} جنيه', isHighlight: true),
                            const Divider(),
                            _buildRow('الحالة', transaction.status),
                            const Divider(),
                            _buildRow('رقم الطلب', '#${transaction.orderId}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('الأطراف المعنية', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 12),
                    SoftCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRow('العميل', transaction.buyerName),
                            const Divider(),
                            _buildRow('المزود', transaction.providerName),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('غير مدعوم حالياً'))),
                      icon: const Icon(Icons.download),
                      label: const Text('تنزيل الإيصال (PDF)'),
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
