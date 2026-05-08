import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/data/models/seller_models.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/widgets/common/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/presentation/providers/seller_provider.dart';

class SellerManageOrdersView extends StatefulWidget {
  const SellerManageOrdersView({super.key});

  @override
  State<SellerManageOrdersView> createState() => _SellerManageOrdersViewState();
}

class _SellerManageOrdersViewState extends State<SellerManageOrdersView> {
  // null = الكل
  String? _selectedStatus;

  static const _statusFilters = <String?>[
    null,
    'Request',
    'Accepted',
    'Rejected',
  ];
  static const _statusLabels = [
    'الكل',
    'طلبات جديدة',
    'مقبولة',
    'مرفوضة',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  void _load() {
    context.read<SellerProvider>().fetchSellerOrders(
          status: _selectedStatus,
          page: 1,
          pageSize: 20,
        );
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'request':
        return AppColors.statusPending;
      case 'accepted':
        return AppColors.statusActive;
      case 'rejected':
        return AppColors.error;
      case 'paid':
        return Colors.blue;
      case 'inprogress':
        return Colors.orange;
      case 'readyforshipping':
      case 'outfordelivery':
      case 'shipped':
        return Colors.indigo;
      case 'confirmed':
        return AppColors.statusActive;
      default:
        return AppColors.statusInactive;
    }
  }

  String _statusAr(String s) {
    switch (s.toLowerCase()) {
      case 'request':
        return 'طلب جديد';
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'paid':
        return 'مدفوع';
      case 'inprogress':
        return 'قيد التنفيذ';
      case 'readyforshipping':
        return 'جاهز للشحن';
      case 'outfordelivery':
        return 'في الطريق';
      case 'shipped':
        return 'تم الشحن';
      case 'confirmed':
        return 'مكتمل';
      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const GradientAppBar(
            title: 'إدارة الطلبات',
          ),
          // Status filter chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _statusFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final isSelected = _selectedStatus == _statusFilters[i];
                return FilterChip(
                  label: Text(_statusLabels[i]),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedStatus = _statusFilters[i]);
                    _load();
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<SellerProvider>(
              builder: (context, provider, _) {
                final items = provider.ordersResponse?.items ?? [];

                if (provider.isLoadingOrders && items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.ordersError != null && items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.ordersError!,
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

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'مفيش طلبات هنا دلوقتي.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _OrderCard(
                        item: item,
                        statusColor: _statusColor(item.status),
                        statusAr: _statusAr(item.status),
                        onTap: () =>
                            context.push('/seller/order-details/${item.id}'),
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.item,
    required this.statusColor,
    required this.statusAr,
    required this.onTap,
  });

  final SellerOrderListItem item;
  final Color statusColor;
  final String statusAr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = item.createdAt != null
        ? DateFormat('dd/MM/yyyy').format(item.createdAt!)
        : '';

    return SoftCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.orderCode.isNotEmpty ? item.orderCode : 'طلب #${item.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusAr,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.serviceTitle,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.providerName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.totalPrice.toStringAsFixed(2)} جنيه',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              if (dateStr.isNotEmpty)
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
