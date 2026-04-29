import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class DeliveryDetailsView extends StatelessWidget {
  const DeliveryDetailsView({super.key, required this.deliveryId});
  
  final String deliveryId;

  @override
  Widget build(BuildContext context) {
    // TODO: Connect to backend API to fetch exact delivery details using deliveryId
    
    return Scaffold(

      appBar: AppBar(
        title: Text('تفاصيل طلب #$deliveryId'),
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
                    'المسار',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildStep(
                    title: 'مكان الاستلام',
                    subtitle: 'صيدلية العزبي - شارع التحرير، الدقي',
                    icon: Icons.storefront,
                    isActive: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15, top: 4, bottom: 4),
                    child: Container(
                      width: 2,
                      height: 24,
                      color: AppColors.textHint,
                    ),
                  ),
                  _buildStep(
                    title: 'مكان التسليم',
                    subtitle: 'شارع السودان - المهندسين، عمارة ١٢',
                    icon: Icons.location_on,
                    isActive: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تفاصيل الطلب',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text('١x أدوية طبية'),
                  const SizedBox(height: 8),
                  const Text('ملاحظات: برجاء التأكد من وجود الدواء س قبل الاستلام', style: TextStyle(color: AppColors.textSecondary)),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('أجرة التوصيل', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Text('35 جنيه', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              // Confirm Start Delivery flow -> then navigate to Verification
              _showStartDeliveryDialog(context);
            },
            child: const Text('بدء التوصيل'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({required String title, required String subtitle, required IconData icon, required bool isActive}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: isActive ? AppColors.primary : AppColors.textSecondary, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isActive ? AppColors.primary : Colors.black)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  void _showStartDeliveryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد بدء التوصيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text('هل أنت متأكد أنك قمت باستلام الطلب وأنت الآن في طريقك للعميل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pushReplacement('/delivery/verification/$deliveryId');
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
