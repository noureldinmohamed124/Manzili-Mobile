import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class AdminTransactionDetailsView extends StatelessWidget {
  const AdminTransactionDetailsView({super.key, required this.transactionId});
  
  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تفاصيل $transactionId'),
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
                  const Text('بيانات المعاملة', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildDetailRow('تاريخ المعاملة', '20 مايو 2026 10:30 ص'),
                  const Divider(),
                  _buildDetailRow('النوع', 'تحويل أرباح لبائع'),
                  const Divider(),
                  _buildDetailRow('المبلغ', '200 جنيه', isHighlight: true),
                  const Divider(),
                  _buildDetailRow('الحالة', 'مكتمل'),
                  const Divider(),
                  _buildDetailRow('المرجع البنكي', 'REF-9876543210'),
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
                  _buildDetailRow('من', 'محفظة المنصة'),
                  const Divider(),
                  _buildDetailRow('إلى', 'أحمد محمود (بائع)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download),
            label: const Text('تنزيل الإيصال (PDF)'),
          ),
          const SizedBox(height: 12),
          if (false) // Mocking a pending state
            FilledButton(
              onPressed: () {},
              child: const Text('اعتماد المعاملة'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
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
