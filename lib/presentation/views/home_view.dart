import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/data/models/service_models.dart';
import 'package:manzili_mobile/presentation/providers/favourites_provider.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import 'package:manzili_mobile/presentation/widgets/home/food_list_section.dart';
import 'package:manzili_mobile/presentation/widgets/home/food_card.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/responsive_max_width.dart';
import 'package:manzili_mobile/presentation/providers/theme_provider.dart';
import 'package:manzili_mobile/presentation/providers/locale_provider.dart';
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
      final servicesProvider = context.read<ServicesProvider>();
      servicesProvider.fetchHomeBuckets(4);
      servicesProvider.fetchServices(page: 1, pageSize: 10);
      servicesProvider.fetchFeaturedServices(page: 1, pageSize: 10);
      servicesProvider.fetchRecommendedServices(page: 1, pageSize: 10);
      servicesProvider.fetchMostPurchasedServices(page: 1, pageSize: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use effective width for scaling to prevent over-scaling on ultra-wide screens
          final spacing = ResponsiveHelper.responsiveSpacingFromConstraints(
            constraints,
            base: 8.0,
          );
          final horizontalPadding =
              ResponsiveHelper.responsiveHorizontalPaddingFromConstraints(
                constraints,
              );

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              bottom: false,
              child: ResponsiveMaxWidth(
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.only(
                        top: spacing,
                        bottom:
                            ResponsiveHelper.responsiveSpacingFromConstraints(
                              constraints,
                              base: 12.0,
                            ),
                      ).add(horizontalPadding),
                      child: LayoutBuilder(
                        builder: (context, headerConstraints) {
                          final iconSize = ResponsiveHelper.scaleValue(
                            40.0,
                            headerConstraints.maxWidth,
                            min: 36.0,
                            max: 48.0,
                          );

                          return Row(
                            children: [
                              // Left Icons - Use Wrap for very small screens
                              LayoutBuilder(
                                builder: (context, iconConstraints) {
                                  if (iconConstraints.maxWidth < 200) {
                                    // Very narrow: stack icons vertically or use Wrap
                                    return Wrap(
                                      spacing: spacing,
                                      children: [
                                        _buildIconButton(
                                          Icons.notifications_outlined,
                                          Theme.of(context).iconTheme.color ??
                                              AppColors.textSecondary,
                                          Theme.of(context).colorScheme.surface,
                                          iconSize,
                                          () => context.push('/notifications'),
                                        ),
                                        _buildIconButton(
                                          Icons.shopping_cart_outlined,
                                          Colors.white,
                                          AppColors.primary,
                                          iconSize,
                                          () => context.push('/cart'),
                                        ),
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      _buildIconButton(
                                        Icons.notifications_outlined,
                                        Theme.of(context).iconTheme.color ??
                                            AppColors.textSecondary,
                                        Theme.of(context).colorScheme.surface,
                                        iconSize,
                                        () => context.push('/notifications'),
                                      ),
                                      SizedBox(width: spacing),
                                      _buildIconButton(
                                        Icons.shopping_cart_outlined,
                                        Colors.white,
                                        AppColors.primary,
                                        iconSize,
                                        () => context.push('/cart'),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              // Search Bar
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: spacing,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        ResponsiveHelper.responsiveSpacingFromConstraints(
                                          constraints,
                                          base: 16.0,
                                        ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    textInputAction: TextInputAction.search,
                                    onSubmitted: (value) {
                                      final q = value.trim();
                                      if (q.isEmpty) return;
                                      context.go(
                                        Uri(
                                          path: '/services',
                                          queryParameters: {'q': q},
                                        ).toString(),
                                      );
                                    },
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveHelper.responsiveFontSize(
                                            context,
                                            base: 14.0,
                                            min: 12.0,
                                            max: 16.0,
                                          ),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'دور على إيه؟ اكتب هنا',
                                      hintStyle: TextStyle(
                                        color: AppColors.textHint,
                                        fontSize:
                                            ResponsiveHelper.responsiveFontSize(
                                              context,
                                              base: 14.0,
                                              min: 12.0,
                                              max: 16.0,
                                            ),
                                      ),
                                      border: InputBorder.none,
                                      suffixIcon: Icon(
                                        Icons.search,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: spacing),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => context.push('/profile'),
                                  customBorder: const CircleBorder(),
                                  child: Container(
                                    width: iconSize,
                                    height: iconSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.coolSteel.withValues(
                                          alpha: 0.45,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Container(
                                        color: AppColors.surfaceMuted,
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: AppColors.heading,
                                          size: iconSize * 0.55,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: spacing),
                              Consumer2<ThemeProvider, LocaleProvider>(
                                builder:
                                    (
                                      context,
                                      themeProvider,
                                      localeProvider,
                                      _,
                                    ) {
                                      return Row(
                                        children: [
                                          _buildIconButton(
                                            themeProvider.isDarkMode
                                                ? Icons.light_mode
                                                : Icons.dark_mode,
                                            Theme.of(context).iconTheme.color ??
                                                AppColors.textSecondary,
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                            iconSize,
                                            () => themeProvider.toggleTheme(),
                                          ),
                                          SizedBox(width: spacing),
                                          _buildIconButton(
                                            Icons.language,
                                            Theme.of(context).iconTheme.color ??
                                                AppColors.textSecondary,
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                            iconSize,
                                            () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'تغيير اللغة غير مفعل حالياً',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Title Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical:
                            ResponsiveHelper.responsiveSpacingFromConstraints(
                              constraints,
                              base: 16.0,
                            ),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final p = context.read<ServicesProvider>();
                              p.fetchHomeBuckets(4);
                              p.fetchServices(page: 1, pageSize: 10);
                              p.fetchFeaturedServices(page: 1, pageSize: 10);
                              p.fetchRecommendedServices(page: 1, pageSize: 10);
                              p.fetchMostPurchasedServices(
                                page: 1,
                                pageSize: 10,
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context)!.appName,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.responsiveFontSize(
                                  context,
                                  base: 32.0,
                                  min: 24.0,
                                  max: 48.0,
                                ),
                                fontWeight: FontWeight.w900,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.displayLarge?.color ??
                                    AppColors.heading,
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                ResponsiveHelper.responsiveSpacingFromConstraints(
                                  constraints,
                                  base: 4.0,
                                ),
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing:
                                ResponsiveHelper.responsiveSpacingFromConstraints(
                                  constraints,
                                  base: 4.0,
                                ),
                            children: [
                              AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    AppLocalizations.of(
                                      context,
                                    )!.homeHeaderSubtitle,
                                    textStyle: TextStyle(
                                      fontSize:
                                          ResponsiveHelper.responsiveFontSize(
                                            context,
                                            base: 14.0,
                                            min: 12.0,
                                            max: 16.0,
                                          ),
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.color ??
                                          AppColors.textSecondary,
                                    ),
                                    speed: const Duration(milliseconds: 100),
                                  ),
                                ],
                                totalRepeatCount: 1,
                              ),
                              Text(
                                '👋',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.responsiveFontSize(
                                    context,
                                    base: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Content
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          top:
                              ResponsiveHelper.responsiveSpacingFromConstraints(
                                constraints,
                                base: 16.0,
                              ),
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(
                              ResponsiveHelper.responsiveValueFromConstraints(
                                constraints,
                                base: 30.0,
                                lg: 32.0,
                              ),
                            ),
                          ),
                        ),
                        child: Consumer<ServicesProvider>(
                          builder: (context, servicesProvider, _) {
                            final buckets = servicesProvider.homeBuckets;
                            final featured =
                                buckets != null &&
                                    buckets.topDiscounts.isNotEmpty
                                ? buckets.topDiscounts
                                : servicesProvider.featuredServices;
                            final recommended =
                                buckets != null &&
                                    buckets.recommended.isNotEmpty
                                ? buckets.recommended
                                : servicesProvider.recommendedServices;
                            final mostSold =
                                buckets != null &&
                                    buckets.mostPurchased.isNotEmpty
                                ? buckets.mostPurchased
                                : servicesProvider.mostPurchasedServices;
                            final allServices =
                                buckets != null && buckets.regular.isNotEmpty
                                ? buckets.regular
                                : servicesProvider.services;

                            final bool isInitialLoading =
                                servicesProvider.isLoading &&
                                featured.isEmpty &&
                                recommended.isEmpty &&
                                mostSold.isEmpty &&
                                allServices.isEmpty;

                            if (isInitialLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (servicesProvider.errorMessage != null &&
                                featured.isEmpty &&
                                recommended.isEmpty &&
                                mostSold.isEmpty &&
                                allServices.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        servicesProvider.errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.error,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      FilledButton(
                                        onPressed: () {
                                          servicesProvider.fetchHomeBuckets(4);
                                          servicesProvider.fetchServices(
                                            page: 1,
                                            pageSize: 10,
                                          );
                                          servicesProvider
                                              .fetchFeaturedServices(
                                                page: 1,
                                                pageSize: 10,
                                              );
                                          servicesProvider
                                              .fetchRecommendedServices(
                                                page: 1,
                                                pageSize: 10,
                                              );
                                          servicesProvider
                                              .fetchMostPurchasedServices(
                                                page: 1,
                                                pageSize: 10,
                                              );
                                        },
                                        child: const Text('جرّب تاني'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return SmartRefresher(
                              controller: _refreshController,
                              header: WaterDropMaterialHeader(
                                backgroundColor: AppColors.primary,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              onRefresh: () async {
                                final p = context.read<ServicesProvider>();
                                p.fetchHomeBuckets(4);
                                p.fetchServices(page: 1, pageSize: 10);
                                p.fetchFeaturedServices(page: 1, pageSize: 10);
                                p.fetchRecommendedServices(
                                  page: 1,
                                  pageSize: 10,
                                );
                                p.fetchMostPurchasedServices(
                                  page: 1,
                                  pageSize: 10,
                                );
                                await Future.delayed(
                                  const Duration(seconds: 1),
                                );
                                _refreshController.refreshCompleted();
                              },
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _HomeQuickCategories(
                                      onCategoryTap: (id) => id == null
                                          ? context.go('/services')
                                          : context.go(
                                              '/services?categoryId=$id',
                                            ),
                                    ),
                                    if (featured.isNotEmpty)
                                      FoodListSection(
                                        title: 'أقوى العروض',
                                        titleIcon: Icons.percent,
                                        titleIconColor: Colors.red,
                                        foodItems: _buildFoodCardsFromServices(
                                          context,
                                          constraints,
                                          featured,
                                          badge: AppStrings.badgeDiscount,
                                        ),
                                      ),

                                    if (featured.isNotEmpty)
                                      SizedBox(
                                        height:
                                            ResponsiveHelper.responsiveSpacingFromConstraints(
                                              constraints,
                                              base: 8.0,
                                            ),
                                      ),

                                    if (recommended.isNotEmpty)
                                      FoodListSection(
                                        title: 'خدمات مرشّحة ليك',
                                        foodItems: _buildFoodCardsFromServices(
                                          context,
                                          constraints,
                                          recommended,
                                          badge: 'مرشّح',
                                        ),
                                      ),

                                    if (recommended.isNotEmpty)
                                      SizedBox(
                                        height:
                                            ResponsiveHelper.responsiveSpacingFromConstraints(
                                              constraints,
                                              base: 8.0,
                                            ),
                                      ),

                                    if (mostSold.isNotEmpty)
                                      FoodListSection(
                                        title: 'الأكتر مبيعًا',
                                        titleIcon: Icons.star,
                                        titleIconColor: Colors.amber,
                                        foodItems: _buildFoodCardsFromServices(
                                          context,
                                          constraints,
                                          mostSold,
                                          badge: AppStrings.badgeTopSold,
                                        ),
                                      ),

                                    if (mostSold.isNotEmpty)
                                      SizedBox(
                                        height:
                                            ResponsiveHelper.responsiveSpacingFromConstraints(
                                              constraints,
                                              base: 8.0,
                                            ),
                                      ),

                                    if (allServices.isNotEmpty)
                                      FoodListSection(
                                        title: 'كل الخدمات',
                                        viewAllText: 'عرض الكل',
                                        onViewAllTap: () =>
                                            context.go('/services'),
                                        onTitleTap: () =>
                                            context.go('/services'),
                                        foodItems: _buildFoodCardsFromServices(
                                          context,
                                          constraints,
                                          allServices,
                                        ),
                                      ),

                                    SizedBox(
                                      height:
                                          ResponsiveHelper.responsiveSpacingFromConstraints(
                                            constraints,
                                            base: 20.0,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFoodCardsFromServices(
    BuildContext context,
    BoxConstraints constraints,
    List<ServiceItem> services, {
    String? badge,
  }) {
    return services.map((service) {
      return Consumer<FavouritesProvider>(
        builder: (context, fav, _) {
          return FoodCard(
            networkImageUrl: service.imageUrl,
            name: service.title,
            sellerName: service.providerName,
            price: service.basePrice.toDouble(),
            rating: service.rating.toDouble(),
            badge: badge,
            isFavorite: fav.isFavourite(service.id),
            onFavoriteTap: () => fav.toggle(service),
            onTap: () => context.push('/service/${service.id}'),
          );
        },
      );
    }).toList();
  }

  Widget _buildIconButton(
    IconData icon,
    Color iconColor,
    Color bgColor,
    double size,
    VoidCallback onPressed,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon),
        color: iconColor,
        onPressed: onPressed,
      ),
    );
  }
}

/// Spec: quick categories horizontal scroll (filters → services list).
class _HomeQuickCategories extends StatelessWidget {
  const _HomeQuickCategories({required this.onCategoryTap});

  final void Function(int?) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22),
        ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12),
        ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22),
        ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8),
      ),
      child: SizedBox(
        height: 40,
        child: Consumer<ServicesProvider>(
          builder: (context, provider, child) {
            final categories = provider.categories;
            if (categories.isEmpty) return const SizedBox.shrink();

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (_, __) => SizedBox(
                width: ResponsiveHelper.responsiveSpacingCompat(
                  context,
                  mobile: 8,
                ),
              ),
              itemBuilder: (context, i) {
                final isAll = i == 0;
                final label = isAll ? 'الكل' : categories[i - 1].nameAr;
                final onTap = isAll
                    ? () => onCategoryTap(null)
                    : () => onCategoryTap(categories[i - 1].id);

                return _CategoryChip(label: label, onTap: onTap);
              },
            );
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: BorderSide(color: Theme.of(context).dividerColor),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      onPressed: onTap,
    );
  }
}
