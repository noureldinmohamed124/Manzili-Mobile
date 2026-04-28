import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class AdminServiceDetailsView extends StatelessWidget {
  const AdminServiceDetailsView({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تفاصيل الخدمة #$serviceId'),
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
                  const Text(
                    'خدمة كروشيه حسب المقاس (شيلان وملابس شتوي)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  const Text('بواسطة: Mona Crochet (ID: 104)'),
                  const SizedBox(height: 16),
                  const Text('الوصف', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text(
                    'تفصيل يدوي حسب المقاس.. خامات ممتازة، وألوان على مزاجك، وتسليم في الميعاد.',
                    style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const Divider(height: 32),
                  const Text('بيانات إضافية', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildRow('السعر', 'يبدأ من 700 جنيه'),
                  _buildRow('القسم', 'هاند ميد / كروشيه'),
                  _buildRow('الحالة', 'مراجعة (Pending)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('إجراءات الإدارة', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Reject Service API
                    context.pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('رفض الخدمة'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    // TODO: Approve Service API
                    context.pop();
                  },
                  child: const Text('اعتماد ونشر'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
