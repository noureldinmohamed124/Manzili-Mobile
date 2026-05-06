import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/presentation/providers/orders_provider.dart';

class SellerManageOrdersView extends StatefulWidget {
  const SellerManageOrdersView({super.key});

  @override
  State<SellerManageOrdersView> createState() => _SellerManageOrdersViewState();
}

class _SellerManageOrdersViewState extends State<SellerManageOrdersView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

    return Scaffold(

      appBar: AppBar(
        title: const Text('إدارة الطلبات'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'طلبات جديدة'),
            Tab(text: 'طلبات نشطة'),
          ],
        ),
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, child) {
          if (ordersProvider.isLoading && ordersProvider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ordersProvider.errorMessage != null && ordersProvider.orders.isEmpty) {
            return Center(
              child: Text(
                ordersProvider.errorMessage!,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          final allOrders = ordersProvider.orders;
          
          // Pending = 'Pending' status (or equivalent for new requests)
          final pendingRequests = allOrders.where((o) => 
            o.status?.toLowerCase() == 'pending').toList();
            
          // Active = anything not pending and not finished/cancelled
          final activeOrders = allOrders.where((o) => 
            o.status?.toLowerCase() != 'pending' && 
            o.status?.toLowerCase() != 'cancelled' && 
            o.status?.toLowerCase() != 'completed' &&
            o.status?.toLowerCase() != 'delivered').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(pendingRequests, isPending: true),
              _buildList(activeOrders, isPending: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<dynamic> items, {required bool isPending}) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          isPending ? 'لا توجد طلبات جديدة.' : 'لا توجد طلبات نشطة حالياً.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return SoftCard(
          onTap: () {
            context.push('/seller/order-details/${item.id}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طلب #${item.id}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  if (isPending)
                    Text(
                      item.createdAt?.toLocal().toString().split(' ')[0] ?? '',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusPending.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.status ?? 'مجهول',
                        style: const TextStyle(color: AppColors.statusPending, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.serviceName ?? 'خدمة بدون اسم',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'المبلغ: ${item.totalAmount} جنيه',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
