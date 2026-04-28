import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Connect to backend API for seller's incoming requests
    final pendingRequests = [
      {
        'id': '1046',
        'service': 'بوكسات سينابون (طلب جديد)',
        'price': '300 جنيه',
        'time': 'منذ 10 دقائق',
      },
    ];

    final activeOrders = [
      {
        'id': '1042',
        'service': 'كحك وبسكوت العيد',
        'price': '250 جنيه',
        'status': 'جاري التحضير',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(pendingRequests, isPending: true),
          _buildList(activeOrders, isPending: false),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, String>> items, {required bool isPending}) {
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
            context.push('/seller/order-details/${item['id']}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طلب #${item['id']}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  if (isPending)
                    Text(
                      item['time']!,
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
                        item['status']!,
                        style: const TextStyle(color: AppColors.statusPending, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item['service']!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'المبلغ: ${item['price']}',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
