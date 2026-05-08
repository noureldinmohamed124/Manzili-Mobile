import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/data/models/order_models.dart';
import 'package:manzili_mobile/presentation/providers/orders_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// أوردراتي — post-payment execution screen.
///
/// Only shows orders that have been paid and are in the execution/delivery
/// lifecycle. Pre-payment statuses live in RequestsListView (طلباتي).
///
///   Paid → InProgress → ReadyForShipping → OutForDelivery → Shipped → Confirmed
class OrdersListView extends StatefulWidget {
  const OrdersListView({super.key});

  @override
  State<OrdersListView> createState() => _OrdersListViewState();
}

class _OrdersListViewState extends State<OrdersListView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Pre-payment statuses (request, accepted, pendingpaymentverification)
  // are handled by RequestsListView (طلباتي).
  static const _activeStatuses = {
    'paid',
    'inprogress',
    'readyforshipping',
    'outfordelivery',
    'shipped',
  };
  static const _doneStatuses = {'confirmed'};
  static const _cancelledStatuses = {'rejected', 'cancelled'};

  static String _statusAr(String s) {
    switch (s.toLowerCase()) {
      case 'paid':               return 'مدفوع';
      case 'inprogress':         return 'قيد التنفيذ';
      case 'readyforshipping':   return 'جاهز للشحن';
      case 'outfordelivery':     return 'في الطريق';
      case 'shipped':            return 'تم الشحن';
      case 'confirmed':          return 'مكتمل';
      case 'rejected':           return 'مرفوض';
      case 'cancelled':          return 'ملغي';
      default:                   return s;
    }
  }

  static Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'paid':               return const Color(0xFF1565C0); // TODO: move to AppColors
      case 'inprogress':         return const Color(0xFFE65100); // TODO: move to AppColors
      case 'readyforshipping':
      case 'outfordelivery':
      case 'shipped':            return const Color(0xFF283593); // TODO: move to AppColors
      case 'confirmed':          return AppColors.statusActive;
      case 'rejected':
      case 'cancelled':          return AppColors.error;
      default:                   return AppColors.statusInactive;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? [const Color(0xFF2A1A14), const Color(0xFF1A1A1A)]
                    : [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'أوردراتي',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              context.read<OrdersProvider>().fetchOrders(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.refresh_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        Colors.white.withValues(alpha: 0.6),
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'قيد التنفيذ'),
                      Tab(text: 'مكتملة'),
                      Tab(text: 'ملغاة'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ── Body ────────────────────────────────────────────────────
          Expanded(
            child: Consumer<OrdersProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null &&
                    provider.orders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.error.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.wifi_off_rounded,
                                size: 48, color: AppColors.error),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => provider.fetchOrders(),
                            icon: const Icon(Icons.refresh_rounded,
                                size: 18),
                            label: const Text('جرّب تاني'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final active = provider.orders
                    .where((o) =>
                        _activeStatuses.contains(o.status.toLowerCase()))
                    .toList();
                final done = provider.orders
                    .where((o) =>
                        _doneStatuses.contains(o.status.toLowerCase()))
                    .toList();
                final cancelled = provider.orders
                    .where((o) =>
                        _cancelledStatuses.contains(o.status.toLowerCase()))
                    .toList();

                return RefreshIndicator(
                  onRefresh: () => provider.fetchOrders(),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      active.isEmpty
                          ? _emptyState('لا توجد طلبات قيد التنفيذ',
                              Icons.pending_actions_rounded)
                          : _orderList(active),
                      done.isEmpty
                          ? _emptyState('لا توجد طلبات مكتملة',
                              Icons.check_circle_outline_rounded)
                          : _orderList(done),
                      cancelled.isEmpty
                          ? _emptyState('لا توجد طلبات ملغاة',
                              Icons.cancel_outlined)
                          : _orderList(cancelled),
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

  Widget _orderList(List<OrderListItem> orders) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final o = orders[i];
        final statusColor = _statusColor(o.status);
        final dateStr = o.createdAt != null
            ? DateFormat('dd MMM yyyy', 'ar').format(o.createdAt!)
            : '';
        return SoftCard(
          onTap: () => context.push('/track-order'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'أوردر #${o.id}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusAr(o.status),
                      style: TextStyle(
                        color: statusColor, fontWeight: FontWeight.w600, fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(o.serviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('بواسطة: ${o.providerName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${o.totalPrice.toStringAsFixed(2)} جنيه',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.orderCardCta,
                style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.go('/home'),
            child: const Text(AppStrings.browseServicesCta),
          ),
        ],
      ),
    );
  }
}
