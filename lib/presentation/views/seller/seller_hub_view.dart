import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/providers/seller_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:provider/provider.dart';

class SellerHubView extends StatefulWidget {
  const SellerHubView({super.key});

  @override
  State<SellerHubView> createState() => _SellerHubViewState();
}

class _SellerHubViewState extends State<SellerHubView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerProvider>().fetchDashboardStats();
    });
  }

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
      body: Consumer<SellerProvider>(
        builder: (context, seller, _) {
          final stats = seller.stats;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SoftCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ملخص سريع',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    if (seller.isLoadingDashboard && stats == null)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(),
                      ))
                    else if (seller.dashboardError != null && stats == null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seller.dashboardError!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton(
                            onPressed: () => seller.fetchDashboardStats(),
                            child: const Text('جرّب تاني'),
                          ),
                        ],
                      )
                    else if (stats != null)
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _StatChip(label: 'الخدمات', value: stats.totalServices.toString()),
                          _StatChip(label: 'طلبات شغالة', value: stats.activeOrders.toString()),
                          _StatChip(label: 'طلبات مكتملة', value: stats.completedOrders.toString()),
                          _StatChip(label: 'الإيراد', value: '${stats.totalRevenue.toStringAsFixed(2)}ج'),
                          _StatChip(label: 'التقييم', value: stats.averageRating.toStringAsFixed(1)),
                        ],
                      )
                    else
                      const Text(
                        'مفيش بيانات دلوقتي.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
            ],
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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: AppColors.heading,
            ),
          ),
        ],
      ),
    );
  }
}
