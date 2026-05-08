import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/widgets/common/gradient_app_bar.dart';

class AdminAnnouncementsView extends StatelessWidget {
  const AdminAnnouncementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final mockAnnouncements = [
      {'title': 'تحديث سياسة الاستخدام', 'date': '20 مايو 2026', 'audience': 'الجميع'},
      {'title': 'مكافآت المندوبين', 'date': '15 مايو 2026', 'audience': 'المندوبين'},
    ];

    return Scaffold(
      body: Column(
        children: [
          GradientAppBar(
            title: 'الإعلانات والتنبيهات',
            actions: [
              GradientAppBarAction(
                icon: Icons.add,
                onTap: () => context.push('/admin/announcements/new'),
              ),
            ],
          ),
          Expanded(
            child: mockAnnouncements.isEmpty
                ? const Center(child: Text('لا توجد إعلانات سابقة.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: mockAnnouncements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ann = mockAnnouncements[index];
                      return SoftCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ann['title']!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('الجمهور: ${ann['audience']}', style: const TextStyle(color: AppColors.textSecondary)),
                                  Text(ann['date']!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
