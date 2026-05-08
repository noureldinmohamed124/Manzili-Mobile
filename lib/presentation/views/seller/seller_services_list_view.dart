import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/data/models/seller_models.dart';
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
  // null = الكل — client-side filter only
  String? _selectedStatus;

  // Full list from API; _filteredServices is derived from this
  List<SellerServiceListItem> _allServices = [];

  static const _statusFilters = <String?>[null, 'Active', 'Draft', 'Blocked'];
  static const _statusLabels = ['الكل', 'نشط', 'مسودة', 'موقوف'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  void _load() {
    // Always load all services without status filter — filtering is client-side
    context.read<SellerProvider>().fetchSellerServices(
          page: 1,
          pageSize: 50,
        );
  }

  List<SellerServiceListItem> _applyFilter(List<SellerServiceListItem> all) {
    if (_selectedStatus == null) return all;
    return all
        .where((s) => s.status.trim().toLowerCase() ==
            _selectedStatus!.trim().toLowerCase())
        .toList();
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

  Future<void> _confirmDelete(
      BuildContext context, int serviceId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هتحذف "$title"؟ الخدمة دي مش هترجع.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('لا'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('أيوه، احذف'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final provider = context.read<SellerProvider>();
    final (ok, err) = await provider.deleteService(serviceId);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الخدمة بنجاح')),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'فشل الحذف')),
      );
    }
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
      body: Column(
        children: [
          // Status filter chips — client-side filtering
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _statusFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final isSelected = _selectedStatus == _statusFilters[i];
                return FilterChip(
                  label: Text(_statusLabels[i]),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedStatus = _statusFilters[i]);
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<SellerProvider>(
              builder: (context, seller, _) {
                // Keep _allServices in sync with provider
                if (!seller.isLoadingServices) {
                  _allServices = seller.sellerServices;
                }

                if (seller.isLoadingServices && _allServices.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (seller.servicesError != null && _allServices.isEmpty) {
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
                            onPressed: _load,
                            child: const Text('جرّب تاني'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filtered = _applyFilter(_allServices);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.design_services_outlined,
                            size: 48, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text(
                          _selectedStatus == null
                              ? 'مفيش خدمات هنا دلوقتي.'
                              : 'مفيش خدمات بالحالة دي.',
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                        ),
                        if (_selectedStatus == null) ...[
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () =>
                                context.push('/seller/create-service'),
                            icon: const Icon(Icons.add),
                            label: const Text('أضف خدمة جديدة'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final s = filtered[index];
                      final c = _statusColor(s.status);
                      final dateStr = s.createdAt != null
                          ? DateFormat('dd/MM/yyyy').format(s.createdAt!)
                          : '';
                      return SoftCard(
                        onTap: () async {
                          // Bug 5 fix: await push so we can reload after returning
                          await context
                              .push('/seller/edit-service/${s.id}');
                          if (context.mounted) _load();
                        },
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
                                  const SizedBox(height: 4),
                                  Text(
                                    '${s.basePrice.toStringAsFixed(0)} جنيه · ${s.category}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (dateStr.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      dateStr,
                                      style: const TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color:
                                              c.withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _statusLabel(s.status),
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
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 14),
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
                              icon: const Icon(Icons.more_vert,
                                  color: AppColors.textHint),
                              onSelected: (val) async {
                                if (val == 'edit') {
                                  await context.push(
                                      '/seller/edit-service/${s.id}');
                                  if (context.mounted) _load();
                                } else if (val == 'delete') {
                                  _confirmDelete(context, s.id, s.title);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('تعديل'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('حذف',
                                      style: TextStyle(color: Colors.red)),
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
          ),
        ],
      ),
    );
  }
}
