import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class SellerOffersListView extends StatelessWidget {
  const SellerOffersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final offers = [
      _OfferUi('خصم الصيف', '٢٥٪', 'كيكة فراولة', '١٠ يونيو', 'نشط'),
      _OfferUi('عرض نهاية الأسبوع', '١٥٪', 'عيش بلدي', '٨ يونيو', 'منتهي'),
    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text(AppStrings.offersTitle),
        actions: [
          IconButton(
            onPressed: () => context.push('/seller/offers/new'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final o = offers[i];
          return SoftCard(
            onTap: () => context.push('/seller/offers/new'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        o.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: o.active
                            ? AppColors.statusActive.withValues(alpha: 0.12)
                            : AppColors.statusInactive.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        o.status,
                        style: TextStyle(
                          color: o.active
                              ? AppColors.statusActive
                              : AppColors.statusInactive,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('الخصم: ${o.discount} · ${o.service}'),
                const SizedBox(height: 4),
                Text(
                  'التاريخ: ${o.date}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
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

class _OfferUi {
  _OfferUi(this.title, this.discount, this.service, this.date, this.status);
  final String title;
  final String discount;
  final String service;
  final String date;
  final String status;

  bool get active => status == 'نشط';
}
