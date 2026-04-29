import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class AdminReportsView extends StatelessWidget {
  const AdminReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text(AppStrings.adminReports)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أداء المنصة',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('تصدير بيانات (CSV)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
