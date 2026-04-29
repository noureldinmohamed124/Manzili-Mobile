import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/providers/theme_provider.dart';
import 'package:manzili_mobile/presentation/providers/locale_provider.dart';
import 'package:provider/provider.dart';

class AdminHubView extends StatelessWidget {
  const AdminHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.adminHub),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, _) {
              return IconButton(
                icon: const Icon(Icons.language),
                onPressed: () {
                  localeProvider.toggleLocale();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/signin');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نظرة سريعة',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetricChip('مستخدمين جدد', '+ ١٢٨'),
                    _MetricChip('طلبات اليوم', '٤٦٠'),
                    _MetricChip('تنبيهات', '٣'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'اختصارات',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          _AdminTile(
            icon: Icons.group_outlined,
            label: AppStrings.adminUsers,
            route: '/admin/users',
          ),
          _AdminTile(
            icon: Icons.design_services_outlined,
            label: AppStrings.adminServices,
            route: '/admin/services',
          ),
          _AdminTile(
            icon: Icons.receipt_long_outlined,
            label: AppStrings.adminOrders,
            route: '/admin/orders',
          ),
          _AdminTile(
            icon: Icons.account_balance_wallet_outlined,
            label: AppStrings.adminFinance,
            route: '/admin/finance',
          ),
          _AdminTile(
            icon: Icons.campaign_outlined,
            label: AppStrings.adminAnnouncements,
            route: '/admin/announcements',
          ),
          _AdminTile(
            icon: Icons.analytics_outlined,
            label: AppStrings.adminReports,
            route: '/admin/reports',
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        onTap: () => context.push(route),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_left),
          ],
        ),
      ),
    );
  }
}
