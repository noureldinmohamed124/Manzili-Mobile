import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class AdminFinanceView extends StatelessWidget {
  const AdminFinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.adminFinance)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('معاملات', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text('هيتم ربطها بالـ API — عرض كروت بدل جداول.'),
              ],
            ),
          ),
          SizedBox(height: 10),
          SoftCard(
            child: Text('استردادات · تحقق من المدفوعات'),
          ),
        ],
      ),
    );
  }
}
