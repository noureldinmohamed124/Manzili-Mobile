import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/seller_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/service_cover_image.dart';
import 'package:provider/provider.dart';

class SellerServicesListView extends StatefulWidget {
  const SellerServicesListView({super.key});

  @override
  State<SellerServicesListView> createState() => _SellerServicesListViewState();
}

class _SellerServicesListViewState extends State<SellerServicesListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerProvider>().fetchSellerServices(page: 1, pageSize: 10);
    });
  }

  Color _statusColor(String s) {
    final v = s.trim().toLowerCase();
    if (v == 'active') return AppColors.statusActive;
    if (v == 'draft') return AppColors.statusPending;
    return AppColors.statusInactive;
  }

  String _statusLabel(String s) {
    final v = s.trim().toLowerCase();
    if (v == 'active') return 'نشط';
    if (v == 'draft') return 'مسودة';
    if (v == 'blocked') return 'موقوف';
    return s.isEmpty ? '—' : s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('خدماتي'),
        actions: [
          IconButton(
            onPressed: () => context.push('/seller/create-service'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<SellerProvider>(
        builder: (context, seller, _) {
          if (seller.isLoadingServices && seller.sellerServices.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (seller.servicesError != null && seller.sellerServices.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      seller.servicesError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => seller.fetchSellerServices(page: 1, pageSize: 10),
                      child: const Text('جرّب تاني'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (seller.sellerServices.isEmpty) {
            return const Center(
              child: Text(
                'ليس لديك أي خدمات حتى الآن.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => seller.fetchSellerServices(page: 1, pageSize: 10),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: seller.sellerServices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = seller.sellerServices[index];
                final c = _statusColor(s.status ?? 'active');
                return SoftCard(
                  onTap: () => context.push('/seller/edit-service/${s.id}'),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ServiceCoverImage(
                          imageUrlRaw: s.image,
                          width: 80,
                          height: 80,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${s.basePrice.toStringAsFixed(0)} جنيه · ${s.category}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: c.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _statusLabel(s.status ?? 'active'),
                                    style: TextStyle(
                                      color: c,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'طلبات: ${s.ordersCount}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  s.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: AppColors.textHint),
                        onSelected: (val) {
                          if (val == 'edit') {
                            context.push('/seller/edit-service/${s.id}');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('الخاصية غير متاحة الآن')),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('تعديل'),
                          ),
                          const PopupMenuItem(
                            value: 'pause',
                            child: Text('إيقاف مؤقت'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('حذف', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
