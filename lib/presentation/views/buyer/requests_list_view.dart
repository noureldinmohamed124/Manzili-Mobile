import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

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
      body: TabBarView(
        controller: _tabController,
        children: [
          _emptyTab(AppStrings.requestsEmptyPending),
          _emptyTab(AppStrings.requestsEmptyApproved),
          _emptyTab(AppStrings.requestsEmptyRejected),
        ],
      ),
    );
  }

  Widget _emptyTab(String message) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SoftCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/services'),
                  child: const Text(AppStrings.browseServicesCta),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
