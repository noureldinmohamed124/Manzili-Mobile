import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/admin_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/gradient_app_bar.dart';
import 'package:provider/provider.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  String? _selectedStatus; // null = all

  static const List<_StatusFilter> _filters = [
    _StatusFilter(label: 'الكل', value: null),
    _StatusFilter(label: 'طلب', value: 'Request'),
    _StatusFilter(label: 'مقبول', value: 'Accepted'),
    _StatusFilter(label: 'قيد التنفيذ', value: 'InProgress'),
    _StatusFilter(label: 'مكتمل', value: 'Completed'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchOrders();
    });
  }

  void _applyStatus(String? status) {
    setState(() => _selectedStatus = status);
    context.read<AdminProvider>().fetchOrders(status: status);
  }

  Future<void> _onRefresh() async {
    await context.read<AdminProvider>().fetchOrders(status: _selectedStatus);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'مكتمل':
        return AppColors.statusActive;
      case 'accepted':
      case 'مقبول':
        return Colors.blue;
      case 'inprogress':
      case 'قيد التنفيذ':
        return Colors.orange;
      case 'cancelled':
      case 'ملغي':
        return Colors.red;
      default:
        return AppColors.statusPending;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'request':
        return 'طلب';
      case 'accepted':
        return 'مقبول';
      case 'inprogress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const GradientAppBar(title: 'إدارة الطلبات'),
          // ── Status filter chips ──────────────────────────────────
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final selected = _selectedStatus == f.value;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () => _applyStatus(f.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.roleUnselectedBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          f.label,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          // ── List ────────────────────────────────────────────────
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.ordersResponse == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage != null && provider.ordersResponse == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _onRefresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                final orders = provider.ordersResponse?.items ?? [];

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        const Text('مفيش طلبات هنا', style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _onRefresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('تحديث'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final statusColor = _statusColor(order.currentStatus);
                      final dateStr = order.createdAt != null
                          ? '${order.createdAt!.day.toString().padLeft(2, '0')}/${order.createdAt!.month.toString().padLeft(2, '0')}/${order.createdAt!.year}'
                          : 'غير معروف';

                      return SoftCard(
                        onTap: () => context.push('/admin/orders/details/${order.orderId}'),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'طلب #${order.orderId}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _statusLabel(order.currentStatus),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                order.serviceTitle,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 14, color: AppColors.textHint),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'العميل: ${order.buyerName}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.store_outlined, size: 14, color: AppColors.textHint),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'المزود: ${order.providerName}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                                    '${order.totalPrice.toStringAsFixed(0)} جنيه',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

class _StatusFilter {
  const _StatusFilter({required this.label, required this.value});
  final String label;
  final String? value;
}
