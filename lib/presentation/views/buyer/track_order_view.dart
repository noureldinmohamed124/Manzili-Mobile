import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class TrackOrderView extends StatelessWidget {
  const TrackOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('اتسجل', true),
      ('قيد التجهيز', true),
      ('خرج للتسليم', false),
      ('تم التسليم', false),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'طلب #١٠٢٣',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ...steps.asMap().entries.map((e) {
                  final done = e.value.$2;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: done
                              ? AppColors.statusActive
                              : AppColors.statusInactive,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          e.value.$1,
                          style: TextStyle(
                            fontWeight: done ? FontWeight.w600 : FontWeight.w500,
                            color: done
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
