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
      _HubItem('اعمل خدمة', Icons.add_circle_outline, '/seller/create-service'),
      _HubItem('تعديل خدمة', Icons.edit_outlined, '/seller/edit-service'),
      _HubItem(AppStrings.earningsTitle, Icons.insights_rounded, '/seller/earnings'),
      _HubItem(AppStrings.vipTitle, Icons.workspace_premium_outlined, '/seller/vip'),
      _HubItem(AppStrings.offersTitle, Icons.local_offer_outlined, '/seller/offers'),
      _HubItem('بوست جديد', Icons.post_add_outlined, '/seller/compose'),
      _HubItem(AppStrings.scheduledPostsTitle, Icons.schedule, '/seller/scheduled'),
      _HubItem(AppStrings.templatesTitle, Icons.article_outlined, '/seller/templates'),
      _HubItem(AppStrings.autoAcceptTitle, Icons.rule_folder_outlined, '/seller/auto-accept'),
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
