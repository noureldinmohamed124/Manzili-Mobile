import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/seller_provider.dart';
import 'package:manzili_mobile/presentation/providers/orders_provider.dart';
import 'package:provider/provider.dart';

class SellerOrderDetailsView extends StatelessWidget {
  const SellerOrderDetailsView({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(orderId) ?? 0;
    final order = context.select<OrdersProvider, dynamic>((p) => p.orders.firstWhere((o) => o.id == id, orElse: () => throw Exception('Not found')));
    
    return Scaffold(

      appBar: AppBar(
        title: Text('تفاصيل طلب #$orderId'),
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
                    'الخدمة المطلوبة',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(order.serviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('العدد: ${order.options.isNotEmpty ? order.options.first.quantity : 1}', style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(
                    'ملاحظات العميل: ${order.customizationDetails.isNotEmpty ? order.customizationDetails : "لا توجد ملاحظات"}',
                    style: const TextStyle(color: AppColors.textSecondary),
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
                    'التكلفة الإجمالية',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('سعر الخدمة'),
                      Text(
                        '${order.totalPrice} جنيه',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Consumer<SellerProvider>(
            builder: (context, provider, _) {
              final id = int.tryParse(orderId) ?? 0;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: provider.isRejecting
                              ? null
                              : () {
                                  final controller = TextEditingController();
                                  showDialog(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('سبب الرفض'),
                                      content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'اكتب السبب هنا...')),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(c), child: const Text('إلغاء')),
                                        FilledButton(
                                          onPressed: () async {
                                            final success = await provider.rejectOrder(id, controller.text);
                                            if (success.$1 && context.mounted) {
                                              Navigator.pop(c);
                                              context.pop();
                                            }
                                          },
                                          child: const Text('رفض'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: provider.isRejecting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('رفض الطلب'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: provider.isApproving
                              ? null
                              : () async {
                                  final success = await provider.approveOrder(id);
                                  if (success.$1 && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الموافقة على الطلب')));
                                    context.pop();
                                  }
                                },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: provider.isApproving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('قبول الطلب'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: provider.isRepricing
                        ? null
                        : () {
                            final priceCtrl = TextEditingController();
                            final reasonCtrl = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('إعادة تسعير'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'السعر الجديد')),
                                    const SizedBox(height: 8),
                                    TextField(controller: reasonCtrl, decoration: const InputDecoration(hintText: 'السبب')),
                                  ],
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c), child: const Text('إلغاء')),
                                  FilledButton(
                                    onPressed: () async {
                                      final p = double.tryParse(priceCtrl.text) ?? 0;
                                      final success = await provider.repriceOrder(id, p, reasonCtrl.text);
                                      if (success.$1 && context.mounted) {
                                        Navigator.pop(c);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال التسعير الجديد')));
                                      }
                                    },
                                    child: const Text('إرسال'),
                                  ),
                                ],
                              ),
                            );
                          },
                    child: provider.isRepricing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('إرسال تسعير جديد للعميل'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
