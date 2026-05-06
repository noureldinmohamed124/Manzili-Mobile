import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/responsive_max_width.dart';
import 'package:gap/gap.dart';

class BuyerOrderDetailsView extends StatelessWidget {
  final String orderId;

  const BuyerOrderDetailsView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveMaxWidth(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رقم الطلب #$orderId',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.statusPending.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'قيد المراجعة',
                          style: TextStyle(color: AppColors.statusPending, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الخدمات المطلوبة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Gap(12),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('خدمة تجهيز بوكسات سينابون'),
                        subtitle: Text('الكمية: ١ • السعر: ٣٠٠ ج.م'),
                        trailing: Text('٣٠٠ ج.م', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('٣٠٠ ج.م', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
