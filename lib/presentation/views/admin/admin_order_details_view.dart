import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class AdminOrderDetailsView extends StatelessWidget {
  const AdminOrderDetailsView({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('طلب #$orderId'),
      ),
      body: ListView(
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
                  _buildRow('العميل', 'أحمد (ID: 482)'),
                  const Divider(),
                  _buildRow('مزود الخدمة', 'محمود (ID: 991)'),
                  const Divider(),
                  _buildRow('المندوب', 'حسن (ID: 104)'),
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
                  _buildRow('الخدمة', 'بوكسات سينابون — طازة من البيت'),
                  const Divider(),
                  _buildRow('المبلغ الإجمالي', '330 جنيه', isHighlight: true),
                  const Divider(),
                  _buildRow('طريقة الدفع', 'محفظة'),
                  const Divider(),
                  _buildRow('حالة الطلب', 'مكتمل'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('إجراءات الإدارة', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.support_agent),
            label: const Text('التواصل مع الأطراف'),
            style: FilledButton.styleFrom(backgroundColor: Colors.blueGrey),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.cancel),
            label: const Text('إلغاء الطلب (إرجاع أموال)'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
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
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight ? AppColors.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
