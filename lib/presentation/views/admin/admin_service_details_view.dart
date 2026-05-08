import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class AdminServiceDetailsView extends StatelessWidget {
  const AdminServiceDetailsView({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الخدمة #$serviceId'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          final services = adminProvider.servicesResponse?.items ?? [];
          final id = int.tryParse(serviceId) ?? 0;
          
          final service = services.where((s) => s.id == id).firstOrNull;

          if (service == null) {
            return const Center(child: Text('الخدمة غير موجودة'));
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
                      Text(
                        service.title,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Text('بواسطة: ${service.providerName} (ID: ${service.providerId})'),
                      const SizedBox(height: 16),
                      const Text('الوصف', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 8),
                      const Text(
                        'لا يتوفر وصف إضافي من الإدارة حالياً',
                        style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                      ),
                      const Divider(height: 32),
                      const Text('بيانات إضافية', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 12),
                      _buildRow('السعر', 'يبدأ من ${service.basePrice} جنيه'),
                      _buildRow('تاريخ الإنشاء', service.createdAt != null ? service.createdAt.toString().split('T')[0] : 'غير معروف'),
                      _buildRow('الحالة', service.status),
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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('غير مدعوم حالياً')));
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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('غير مدعوم حالياً')));
                      },
                      child: const Text('اعتماد ونشر'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
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
              style: const TextStyle(fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
              softWrap: true,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
