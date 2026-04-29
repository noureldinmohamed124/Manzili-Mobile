import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class NotificationsInboxView extends StatefulWidget {
  const NotificationsInboxView({super.key});

  @override
  State<NotificationsInboxView> createState() => _NotificationsInboxViewState();
}

class _NotificationsInboxViewState extends State<NotificationsInboxView> {
  int _filter = 0; // 0 all, 1 orders, 2 messages, 3 system

  @override
  Widget build(BuildContext context) {
    final filters = [
      AppStrings.notifFilterAll,
      AppStrings.notifFilterOrders,
      AppStrings.notifFilterMessages,
      AppStrings.notifFilterSystem,
    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text(AppStrings.notificationsTitle),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('قراها كلها'),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final sel = _filter == i;
                return ChoiceChip(
                  label: Text(filters[i]),
                  selected: sel,
                  onSelected: (_) => setState(() => _filter = i),
                  selectedColor: AppColors.primary.withValues(alpha: 0.25),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                return SoftCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'طلب جديد وصل 🔥',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'عميل طلب منك خدمة — راجع التفاصيل من طلباتي.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
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
