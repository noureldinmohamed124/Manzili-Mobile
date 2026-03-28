import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class AdminOrdersView extends StatelessWidget {
  const AdminOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.adminOrders)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('طلبات تحتاج متابعة', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                TextButton(onPressed: () {}, child: const Text('مشاكل دفع')),
                TextButton(onPressed: () {}, child: const Text('موافقات')),
                TextButton(onPressed: () {}, child: const Text('نزاعات')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
