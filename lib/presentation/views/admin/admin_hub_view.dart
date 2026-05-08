import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/providers/theme_provider.dart';
import 'package:manzili_mobile/presentation/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class AdminHubView extends StatefulWidget {
  const AdminHubView({super.key});

  @override
  State<AdminHubView> createState() => _AdminHubViewState();
}

class _AdminHubViewState extends State<AdminHubView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────
          _GradientHeader(isDark: isDark),

          // ── Scrollable body ──────────────────────────────────────────
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = adminProvider.dashboardStats;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  children: [
                    // ── Stats section ────────────────────────────────
                    _SectionLabel('نظرة سريعة'),
                    const SizedBox(height: 12),
                    if (adminProvider.errorMessage != null)
                      _ErrorBanner(message: adminProvider.errorMessage!)
                    else if (stats != null)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          _MetricCard(
                            icon: Icons.group_rounded,
                            value: '${stats.totalUsers}',
                            label: 'المستخدمين',
                            color: const Color(0xFF5C6BC0),
                          ),
                          _MetricCard(
                            icon: Icons.storefront_rounded,
                            value: '${stats.totalProviders}',
                            label: 'مقدمي الخدمات',
                            color: const Color(0xFF26A69A),
                          ),
                          _MetricCard(
                            icon: Icons.shopping_bag_rounded,
                            value: '${stats.totalBuyers}',
                            label: 'المشترين',
                            color: const Color(0xFF42A5F5),
                          ),
                          _MetricCard(
                            icon: Icons.design_services_rounded,
                            value: '${stats.totalServices}',
                            label: 'إجمالي الخدمات',
                            color: AppColors.primary,
                          ),
                          _MetricCard(
                            icon: Icons.check_circle_rounded,
                            value: '${stats.activeServices}',
                            label: 'الخدمات النشطة',
                            color: AppColors.statusActive,
                          ),
                          _MetricCard(
                            icon: Icons.pending_rounded,
                            value: '${stats.pendingServices}',
                            label: 'الخدمات المعلقة',
                            color: AppColors.statusPending,
                          ),
                          _MetricCard(
                            icon: Icons.receipt_long_rounded,
                            value: '${stats.totalOrders}',
                            label: 'إجمالي الطلبات',
                            color: AppColors.secondary,
                          ),
                          _MetricCard(
                            icon: Icons.trending_up_rounded,
                            value: '${stats.activeOrders}',
                            label: 'الطلبات النشطة',
                            color: const Color(0xFF66BB6A),
                          ),
                          _MetricCard(
                            icon: Icons.task_alt_rounded,
                            value: '${stats.completedOrders}',
                            label: 'الطلبات المكتملة',
                            color: const Color(0xFF26C6DA),
                          ),
                          _MetricCard(
                            icon: Icons.cancel_rounded,
                            value: '${stats.cancelledOrders}',
                            label: 'الطلبات الملغاة',
                            color: AppColors.error,
                          ),
                          _MetricCard(
                            icon: Icons.hourglass_top_rounded,
                            value: '${stats.pendingPayments}',
                            label: 'المدفوعات المعلقة',
                            color: AppColors.statusPending,
                          ),
                          _MetricCard(
                            icon: Icons.account_balance_wallet_rounded,
                            value: '${stats.totalRevenue} ج',
                            label: 'إجمالي الإيرادات',
                            color: AppColors.primary,
                          ),
                        ],
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('لا توجد بيانات متاحة'),
                      ),

                    const SizedBox(height: 28),

                    // ── Navigation tiles ─────────────────────────────
                    _SectionLabel('اختصارات'),
                    const SizedBox(height: 12),
                    _AdminNavCard(
                      icon: Icons.group_outlined,
                      label: AppStrings.adminUsers,
                      color: const Color(0xFF5C6BC0),
                      route: '/admin/users',
                    ),
                    _AdminNavCard(
                      icon: Icons.design_services_outlined,
                      label: AppStrings.adminServices,
                      color: AppColors.primary,
                      route: '/admin/services',
                    ),
                    _AdminNavCard(
                      icon: Icons.receipt_long_outlined,
                      label: AppStrings.adminOrders,
                      color: AppColors.secondary,
                      route: '/admin/orders',
                    ),
                    _AdminNavCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: AppStrings.adminFinance,
                      color: const Color(0xFF26A69A),
                      route: '/admin/finance',
                    ),
                    _AdminNavCard(
                      icon: Icons.campaign_outlined,
                      label: AppStrings.adminAnnouncements,
                      color: const Color(0xFF42A5F5),
                      route: '/admin/announcements',
                    ),
                    _AdminNavCard(
                      icon: Icons.analytics_outlined,
                      label: AppStrings.adminReports,
                      color: const Color(0xFF66BB6A),
                      route: '/admin/reports',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gradient Header ───────────────────────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'لوحة الإدارة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              // Theme toggle
              Consumer<ThemeProvider>(
                builder: (context, tp, _) => _GlassButton(
                  icon: tp.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  onTap: tp.toggleTheme,
                ),
              ),
              const SizedBox(width: 8),
              // Logout
              _GlassButton(
                icon: Icons.logout_rounded,
                onTap: () {
                  context.read<AuthProvider>().logout();
                  context.go('/signin');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Glass Button ──────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 16,
      ),
    );
  }
}

// ── Metric Card ───────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Admin Nav Card ────────────────────────────────────────────────────────────

class _AdminNavCard extends StatelessWidget {
  const _AdminNavCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_left,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Error Banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.error),
      ),
    );
  }
}
