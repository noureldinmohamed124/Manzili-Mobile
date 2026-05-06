import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class AdminFinanceView extends StatefulWidget {
  const AdminFinanceView({super.key});

  @override
  State<AdminFinanceView> createState() => _AdminFinanceViewState();
}

class _AdminFinanceViewState extends State<AdminFinanceView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchFinancials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المالية والمعاملات'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (adminProvider.errorMessage != null) {
            return Center(
              child: Text(adminProvider.errorMessage!, style: const TextStyle(color: AppColors.error)),
            );
          }

          final res = adminProvider.financialsResponse;
          final transactions = res?.items ?? [];
          final totalRevenue = res?.totalRevenue ?? 0.0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SoftCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: _buildMetric('إجمالي الدخل', '$totalRevenue ج')),
                      Container(width: 1, height: 40, color: AppColors.textHint),
                      Expanded(child: _buildMetric('المعلق', '0 ج')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('سجل المعاملات', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 12),
              if (transactions.isEmpty)
                const Center(child: Text('لا توجد معاملات'))
              else
                ...transactions.map((trx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoftCard(
                      onTap: () => context.push('/admin/finance/details/${trx.transactionId}'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TRX-${trx.transactionId}', style: const TextStyle(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(trx.serviceTitle, style: const TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${trx.totalPrice} جنيه', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                const SizedBox(height: 4),
                                Text(
                                  trx.status,
                                  style: TextStyle(
                                      color: trx.status == 'Completed' || trx.status == 'مكتمل' ? AppColors.statusActive : AppColors.statusPending,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary)),
      ],
    );
  }
}
