import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/providers/seller_provider.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SellerHubView extends StatefulWidget {
  const SellerHubView({super.key});

  @override
  State<SellerHubView> createState() => _SellerHubViewState();
}

class _SellerHubViewState extends State<SellerHubView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerProvider>().fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = <_HubItem>[
      _HubItem('خدماتي', Icons.design_services_outlined, '/seller/my-services'),
      _HubItem('إدارة الطلبات', Icons.receipt_long_outlined, '/seller/manage-orders'),
      _HubItem('الخصومات والعروض', Icons.local_offer_outlined, '/seller/discounts'),
      _HubItem(AppStrings.earningsTitle, Icons.account_balance_wallet_outlined, '/seller/earnings'),
      _HubItem('إضافة خدمة جديدة', Icons.add_circle_outline, '/seller/create-service'),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────
          _GradientHeader(isDark: isDark),

          // ── Scrollable body ──────────────────────────────────────────
          Expanded(
            child: Consumer<SellerProvider>(
              builder: (context, seller, _) {
                final stats = seller.stats;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  children: [
                    // ── Stats section ──────────────────────────────────
                    if (seller.isLoadingDashboard && stats == null)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (seller.dashboardError != null && stats == null)
                      _ErrorCard(
                        message: seller.dashboardError!,
                        onRetry: () => seller.fetchDashboardStats(),
                      )
                    else if (stats != null) ...[
                      _SectionLabel('ملخص سريع'),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          _StatCard(
                            icon: Icons.design_services_rounded,
                            value: stats.totalServices.toString(),
                            label: 'الخدمات',
                          ),
                          _StatCard(
                            icon: Icons.pending_actions_rounded,
                            value: stats.activeOrders.toString(),
                            label: 'طلبات شغالة',
                          ),
                          _StatCard(
                            icon: Icons.notification_important_rounded,
                            value: stats.pendingRequests.toString(),
                            label: 'طلبات جديدة',
                          ),
                          _StatCard(
                            icon: Icons.check_circle_outline_rounded,
                            value: stats.completedOrders.toString(),
                            label: 'طلبات مكتملة',
                          ),
                          _StatCard(
                            icon: Icons.account_balance_wallet_rounded,
                            value: '${stats.totalRevenue.toStringAsFixed(0)}ج',
                            label: 'الإيراد',
                          ),
                          _StatCard(
                            icon: Icons.star_rounded,
                            value: stats.averageRating.toStringAsFixed(1),
                            label: 'التقييم',
                          ),
                        ],
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'مفيش بيانات دلوقتي.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ── Quick actions grid ─────────────────────────────
                    _SectionLabel('اختصارات سريعة'),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.05,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final it = items[i];
                        return _ActionCard(
                          label: it.label,
                          icon: it.icon,
                          onTap: () => context.push(it.route),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Placeholder sections ───────────────────────────
                    _buildPlaceholderSection(
                        context, 'أفضل الخدمات مبيعاً', Icons.star_border_outlined),
                    const SizedBox(height: 16),
                    _buildPlaceholderSection(
                        context, 'أحدث الطلبات', Icons.shopping_bag_outlined),
                    const SizedBox(height: 16),
                    _buildPlaceholderSection(
                        context, 'أحدث التقييمات', Icons.rate_review_outlined),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderSection(
      BuildContext context, String title, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
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
          child: Center(
            child: Column(
              children: [
                Icon(Icons.hourglass_empty,
                    color: AppColors.textHint, size: 32),
                const SizedBox(height: 8),
                Text(
                  'لم يتم الإضافة بعد',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
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
                  'لوحة البائع',
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

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
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
                  fontSize: 12,
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

// ── Action Card ───────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 26, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error Card ────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: onRetry,
            child: const Text('جرّب تاني'),
          ),
        ],
      ),
    );
  }
}

// ── Hub Item ──────────────────────────────────────────────────────────────────

class _HubItem {
  _HubItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}
