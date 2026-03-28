import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class SellerScheduledPostsView extends StatelessWidget {
  const SellerScheduledPostsView({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _Sched('عندنا عرض جديد', '١٥ يونيو ٣:٠٠ م', 'مجدول'),
      _Sched('فيديو من المطبخ', '١٨ يونيو ١٠:٠٠ ص', 'مسودة'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.scheduledPostsTitle),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final r = rows[i];
          return SoftCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.when,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(r.status),
                  backgroundColor: AppColors.statusPending.withValues(alpha: 0.15),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Sched {
  _Sched(this.title, this.when, this.status);
  final String title;
  final String when;
  final String status;
}
