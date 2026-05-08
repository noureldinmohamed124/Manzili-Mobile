import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/admin_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/gradient_app_bar.dart';
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

  Future<void> _onRefresh() async {
    await context.read<AdminProvider>().fetchFinancials();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'مكتمل':
        return AppColors.statusActive;
      case 'pending':
      case 'معلق':
        return AppColors.statusPending;
      case 'failed':
      case 'فشل':
        return Colors.red;
      default:
        return AppColors.textHint;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'مكتمل';
      case 'pending':
        return 'معلق';
      case 'failed':
        return 'فشل';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const GradientAppBar(title: 'المالية والمعاملات'),
          Expanded(
            child: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.financialsResponse == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.financialsResponse == null) {
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

          final res = provider.financialsResponse;
          final transactions = res?.items ?? [];
          final totalRevenue = res?.totalRevenue ?? 0.0;

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Revenue summary ──────────────────────────────────
                SoftCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMetric(
                            'إجمالي الدخل',
                            '${totalRevenue.toStringAsFixed(0)} ج',
                          ),
                        ),
                        Container(width: 1, height: 40, color: AppColors.textHint),
                        Expanded(
                          child: _buildMetric(
                            'عدد المعاملات',
                            '${res?.totalCount ?? 0}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'سجل المعاملات',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 12),
                if (transactions.isEmpty)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 32),
                        const Icon(Icons.receipt_outlined, size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        const Text('مفيش معاملات', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                else
                  ...transactions.map((trx) {
                    final statusColor = _statusColor(trx.status);
                    final dateStr = trx.createdAt != null
                        ? '${trx.createdAt!.day.toString().padLeft(2, '0')}/${trx.createdAt!.month.toString().padLeft(2, '0')}/${trx.createdAt!.year}'
                        : 'غير معروف';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SoftCard(
                        onTap: () => context.push('/admin/finance/details/${trx.transactionId}'),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TRX-${trx.transactionId}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _statusLabel(trx.status),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                trx.serviceTitle,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 13, color: AppColors.textHint),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      trx.buyerName,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.store_outlined, size: 13, color: AppColors.textHint),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      trx.providerName,
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
                                    '${trx.totalPrice.toStringAsFixed(0)} جنيه',
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
                      ),
                    );
                  }),
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

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
