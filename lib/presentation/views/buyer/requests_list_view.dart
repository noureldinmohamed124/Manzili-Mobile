import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/data/models/order_models.dart';
import 'package:manzili_mobile/presentation/providers/orders_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// طلباتي — seller decision stage (request → approve / reprice / reject). Wire to API when ready.
class RequestsListView extends StatefulWidget {
  const RequestsListView({super.key});

  @override
  State<RequestsListView> createState() => _RequestsListViewState();
}

class _RequestsListViewState extends State<RequestsListView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchOrders(); // Fetches all orders, we'll filter locally
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.navRequests),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: AppStrings.requestTabPending),
            Tab(text: AppStrings.requestTabApproved),
            Tab(text: AppStrings.requestTabRejected),
          ],
        ),
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.orders.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }

          final pending = provider.orders.where((o) => ['0', 'pending', 'request'].contains(o.status.toLowerCase())).toList();
          final approved = provider.orders.where((o) => ['1', 'approved', 'repriced'].contains(o.status.toLowerCase())).toList();
          final rejected = provider.orders.where((o) => ['2', 'rejected'].contains(o.status.toLowerCase())).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              pending.isEmpty ? _emptyTab(AppStrings.requestsEmptyPending) : _requestList(pending, isApproved: false),
              approved.isEmpty ? _emptyTab(AppStrings.requestsEmptyApproved) : _requestList(approved, isApproved: true),
              rejected.isEmpty ? _emptyTab(AppStrings.requestsEmptyRejected) : _requestList(rejected, isApproved: false),
            ],
          );
        },
      ),
    );
  }

  Widget _requestList(List<OrderListItem> items, {required bool isApproved}) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = items[i];
        final dateStr = item.createdAt != null ? DateFormat('dd MMM yyyy').format(item.createdAt!) : '';
        return SoftCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.serviceName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'بواسطة: ${item.providerName}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                if (item.customizationDetails.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'ملاحظات: ${item.customizationDetails}',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.totalPrice} جنيه',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 15),
                    ),
                    if (isApproved)
                      FilledButton(
                        onPressed: () {
                          // TODO: Go to payment summary view, pass order id
                          context.push('/payment-summary');
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text('ادفع الآن'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyTab(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.list_alt_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go('/home'),
            child: const Text(AppStrings.browseServicesCta),
          ),
        ],
      ),
    );
  }
}
