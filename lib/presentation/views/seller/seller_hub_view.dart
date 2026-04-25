import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class SellerHubView extends StatelessWidget {
  const SellerHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_HubItem>[
      _HubItem('خدماتي', Icons.design_services_outlined, '/seller/my-services'),
      _HubItem('إدارة الطلبات', Icons.receipt_long_outlined, '/seller/manage-orders'),
      _HubItem('الخصومات والعروض', Icons.local_offer_outlined, '/seller/discounts'),
      _HubItem(AppStrings.earningsTitle, Icons.account_balance_wallet_outlined, '/seller/earnings'),
      _HubItem('إضافة خدمة جديدة', Icons.add_circle_outline, '/seller/create-service'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحة البائع'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.05,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final it = items[i];
          return SoftCard(
            onTap: () => context.push(it.route),
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(it.icon, size: 36, color: AppColors.primary),
                const SizedBox(height: 10),
                Text(
                  it.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HubItem {
  _HubItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}
