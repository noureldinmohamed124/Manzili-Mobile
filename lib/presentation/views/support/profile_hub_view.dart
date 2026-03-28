import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class ProfileHubView extends StatelessWidget {
  const ProfileHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.profileTitle),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final isSeller = auth.isAuthenticated && auth.userRole == 2;
          final isAdmin = auth.isAuthenticated && auth.userRole == 3;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SoftCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, size: 36, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.isAuthenticated ? 'أهلاً بيك 👋' : 'أهلاً بيك في منزلي 👋',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            auth.isAuthenticated
                                ? 'هنا تقدر تدير حسابك وأدواتك بسهولة'
                                : 'سجّل دخول عشان تطلب وتتابع طلباتك من مكان واحد',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          if (!auth.isAuthenticated) ...[
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => context.go('/signin'),
                              child: const Text('سجّل دخول'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (isSeller) ...[
                const SectionTitle(AppStrings.sellerTools),
                _LinkTile(
                  icon: Icons.dashboard_customize_outlined,
                  label: 'لوحة البائع',
                  onTap: () => context.push('/seller'),
                ),
                _LinkTile(
                  icon: Icons.add_business_rounded,
                  label: 'اعمل خدمة جديدة',
                  onTap: () => context.push('/seller/create-service'),
                ),
                _LinkTile(
                  icon: Icons.bar_chart_rounded,
                  label: AppStrings.earningsTitle,
                  onTap: () => context.push('/seller/earnings'),
                ),
                _LinkTile(
                  icon: Icons.workspace_premium_rounded,
                  label: AppStrings.vipTitle,
                  onTap: () => context.push('/seller/vip'),
                ),
                _LinkTile(
                  icon: Icons.local_offer_rounded,
                  label: AppStrings.offersTitle,
                  onTap: () => context.push('/seller/offers'),
                ),
                _LinkTile(
                  icon: Icons.campaign_rounded,
                  label: AppStrings.composePostTitle,
                  onTap: () => context.push('/seller/compose'),
                ),
                const SizedBox(height: 16),
              ],
              const SectionTitle(AppStrings.buyerSection),
          _LinkTile(
            icon: Icons.favorite_outline_rounded,
            label: AppStrings.favouritesTitle,
            onTap: () => context.push('/favourites'),
          ),
          _LinkTile(
            icon: Icons.explore_rounded,
            label: AppStrings.exploreSellers,
            onTap: () => context.push('/explore-sellers'),
          ),
          _LinkTile(
            icon: Icons.shopping_cart_outlined,
            label: AppStrings.cart,
            onTap: () => context.push('/cart'),
          ),
          _LinkTile(
            icon: Icons.settings_outlined,
            label: AppStrings.settingsTitle,
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: 16),
          const SectionTitle('مساعدة'),
              _LinkTile(
                icon: Icons.support_agent_rounded,
                label: AppStrings.supportTitle,
                onTap: () => context.push('/support'),
              ),
              if (isAdmin)
                _LinkTile(
                  icon: Icons.admin_panel_settings_outlined,
                  label: AppStrings.adminHub,
                  onTap: () => context.push('/admin'),
                ),
            ],
          );
        },
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
