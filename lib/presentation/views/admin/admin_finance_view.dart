import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class AdminFinanceView extends StatelessWidget {
  const AdminFinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final mockTransactions = [
      {'id': 'TRX-9482', 'amount': '200 جنيه', 'type': 'تحويل لبائع', 'status': 'مكتمل'},
      {'id': 'TRX-9483', 'amount': '35 جنيه', 'type': 'رسوم توصيل', 'status': 'قيد المعالجة'},
      {'id': 'TRX-9484', 'amount': '15 جنيه', 'type': 'عمولة المنصة', 'status': 'مكتمل'},
    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text('المالية والمعاملات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: _buildMetric('إجمالي الدخل', '12,500 ج')),
                  Container(width: 1, height: 40, color: AppColors.textHint),
                  Expanded(child: _buildMetric('المعلق', '1,200 ج')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('سجل المعاملات', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          ...mockTransactions.map((trx) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SoftCard(
                onTap: () => context.push('/admin/finance/details/${trx['id']}'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trx['id']!, style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(trx['type']!, style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(trx['amount']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          const SizedBox(height: 4),
                          Text(
                            trx['status']!,
                            style: TextStyle(
                                color: trx['status'] == 'مكتمل' ? AppColors.statusActive : AppColors.statusPending,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary)),
      ],
    );
  }
}
