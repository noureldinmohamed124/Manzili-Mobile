import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/data/models/service_models.dart';
import 'package:manzili_mobile/presentation/providers/favourites_provider.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import 'package:manzili_mobile/presentation/widgets/home/food_list_section.dart';
import 'package:manzili_mobile/presentation/widgets/home/food_card.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../../../core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/providers/theme_provider.dart';
import 'package:manzili_mobile/l10n/app_localizations.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ServicesProvider>();
      p.fetchHomeBuckets(4);
      p.fetchServices(page: 1, pageSize: 10);
      p.fetchFeaturedServices(page: 1, pageSize: 10);
      p.fetchRecommendedServices(page: 1, pageSize: 10);
      p.fetchMostPurchasedServices(page: 1, pageSize: 10);
      if (p.categories.isEmpty) p.fetchCategories();
    });
  }

  void _refresh() {
    final p = context.read<ServicesProvider>();
    p.fetchHomeBuckets(4);
    p.fetchServices(page: 1, pageSize: 10);
    p.fetchFeaturedServices(page: 1, pageSize: 10);
    p.fetchRecommendedServices(page: 1, pageSize: 10);
    p.fetchMostPurchasedServices(page: 1, pageSize: 10);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Consumer<ServicesProvider>(
          builder: (context, sp, _) {
            final buckets = sp.homeBuckets;
            final featured = (buckets != null && buckets.topDiscounts.isNotEmpty)
                ? buckets.topDiscounts
                : sp.featuredServices;
            final recommended = (buckets != null && buckets.recommended.isNotEmpty)
                ? buckets.recommended
                : sp.recommendedServices;
            final mostSold = (buckets != null && buckets.mostPurchased.isNotEmpty)
                ? buckets.mostPurchased
                : sp.mostPurchasedServices;
            final allServices = (buckets != null && buckets.regular.isNotEmpty)
                ? buckets.regular
                : sp.services;

            final isInitialLoading = sp.isLoading &&
                featured.isEmpty &&
                recommended.isEmpty &&
                mostSold.isEmpty &&
                allServices.isEmpty;

            return SmartRefresher(
              controller: _refreshController,
              header: WaterDropMaterialHeader(
                backgroundColor: AppColors.primary,
                color: Colors.white,
              ),
              onRefresh: () async {
                _refresh();
                await Future.delayed(const Duration(milliseconds: 800));
                _refreshController.refreshCompleted();
              },
              child: CustomScrollView(
                slivers: [
                  // ── Hero header ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _HeroHeader(isDark: isDark),
                  ),

                  // ── Loading / Error ──────────────────────────────────────
                  if (isInitialLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (sp.errorMessage != null &&
                      featured.isEmpty &&
                      recommended.isEmpty &&
                      mostSold.isEmpty &&
                      allServices.isEmpty)
                    SliverFillRemaining(
                      child: _ErrorState(
                        message: sp.errorMessage!,
                        onRetry: _refresh,
                      ),
                    )
                  else ...[
                    // ── Category chips ─────────────────────────────────────
                    SliverToBoxAdapter(
                      child: _CategoryStrip(
                        onTap: (id) => id == null
                            ? context.go('/services')
                            : context.go('/services?categoryId=$id'),
                      ),
                    ),

                    // ── Sections ───────────────────────────────────────────
                    if (featured.isNotEmpty)
                      SliverToBoxAdapter(
                        child: FoodListSection(
                          title: AppLocalizations.of(context)!.homeOffersTitle,
                          titleIcon: Icons.local_offer_rounded,
                          titleIconColor: AppColors.error,
                          foodItems: _cards(context, featured,
                              badge: AppLocalizations.of(context)!.badgeDiscount),
                        ),
                      ),

                    if (recommended.isNotEmpty)
                      SliverToBoxAdapter(
                        child: FoodListSection(
                          title: AppLocalizations.of(context)!.homeRecommendedTitle,
                          titleIcon: Icons.verified_rounded,
                          titleIconColor: AppColors.secondary,
                          foodItems: _cards(context, recommended,
                              badge: AppLocalizations.of(context)!.badgeVip),
                        ),
                      ),

                    if (mostSold.isNotEmpty)
                      SliverToBoxAdapter(
                        child: FoodListSection(
                          title: AppLocalizations.of(context)!.homeMostPurchasedTitle,
                          titleIcon: Icons.trending_up_rounded,
                          titleIconColor: Colors.amber.shade700,
                          foodItems: _cards(context, mostSold,
                              badge: AppLocalizations.of(context)!.badgeTopSold),
                        ),
                      ),

                    if (allServices.isNotEmpty)
                      SliverToBoxAdapter(
                        child: FoodListSection(
                          title: AppLocalizations.of(context)!.homeAllServicesTitle,
                          viewAllText: 'عرض الكل',
                          onViewAllTap: () => context.go('/services'),
                          onTitleTap: () => context.go('/services'),
                          foodItems: _cards(context, allServices),
                        ),
                      ),

                    // bottom padding
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _cards(
    BuildContext context,
    List<ServiceItem> services, {
    String? badge,
  }) {
    return services.map((s) {
      return Consumer<FavouritesProvider>(
        builder: (context, fav, _) => FoodCard(
          networkImageUrl: s.imageUrl,
          name: s.title,
          sellerName: s.providerName,
          price: s.basePrice.toDouble(),
          rating: s.rating.toDouble(),
          badge: badge,
          isFavorite: fav.isFavourite(s.id),
          onFavoriteTap: () => fav.toggle(s),
          onTap: () => context.push('/service/${s.id}'),
        ),
      );
    }).toList();
  }
}

// ── Hero Header ───────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.isDark});
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
              : [
                  AppColors.primary,
                  AppColors.secondary,
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar: avatar + actions
              Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أهلاً بيك 👋',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          'منزلي',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Theme toggle
                  Consumer<ThemeProvider>(
                    builder: (context, tp, _) => _HeaderAction(
                      icon: tp.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      onTap: tp.toggleTheme,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Notifications
                  _HeaderAction(
                    icon: Icons.notifications_outlined,
                    onTap: () => context.push('/notifications'),
                  ),
                  const SizedBox(width: 8),
                  // Cart with badge
                  Consumer<ServicesProvider>(
                    builder: (context, _, __) => _HeaderAction(
                      icon: Icons.shopping_cart_outlined,
                      onTap: () => context.push('/cart'),
                      filled: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search bar
              GestureDetector(
                onTap: () => context.go('/services'),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.homeSearchHint,
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: filled
              ? Colors.white
              : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: filled ? AppColors.primary : Colors.white,
        ),
      ),
    );
  }
}

// ── Category Strip ────────────────────────────────────────────────────────────

class _CategoryStrip extends StatefulWidget {
  const _CategoryStrip({required this.onTap});
  final void Function(int?) onTap;

  @override
  State<_CategoryStrip> createState() => _CategoryStripState();
}

class _CategoryStripState extends State<_CategoryStrip> {
  int? _selected; // null = "الكل"

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesProvider>(
      builder: (context, sp, _) {
        final cats = sp.categories;
        if (cats.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: cats.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final isAll = i == 0;
                final label = isAll ? 'الكل' : cats[i - 1].nameAr;
                final id = isAll ? null : cats[i - 1].id;
                final isSelected = _selected == id;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selected = id);
                    widget.onTap(id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('جرّب تاني'),
            ),
          ],
        ),
      ),
    );
  }
}
