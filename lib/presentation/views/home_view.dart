import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/data/models/service_models.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import 'package:manzili_mobile/presentation/views/service_details_view.dart';
import 'package:manzili_mobile/presentation/widgets/home/food_card.dart';
import 'package:manzili_mobile/presentation/widgets/home/food_list_section.dart';
import 'package:manzili_mobile/presentation/widgets/home/bottom_nav_bar.dart';
import 'package:manzili_mobile/presentation/views/services_view.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/responsive_max_width.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final servicesProvider = context.read<ServicesProvider>();
      // General services list for the "الخدمات" section and ServicesView.
      servicesProvider.fetchServices(page: 1, pageSize: 10);
      // Additional curated lists for the Home sections.
      servicesProvider.fetchFeaturedServices(page: 1, pageSize: 10);
      servicesProvider.fetchRecommendedServices(page: 1, pageSize: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use effective width for scaling to prevent over-scaling on ultra-wide screens
          final effectiveW = ResponsiveHelper.effectiveWidthFromConstraints(constraints);
          final gradientWidth = ResponsiveHelper.scaleValue(
            168.75, // 45% of 375 base width
            effectiveW,
            min: 100.0,
            max: effectiveW * 0.45,
          );
          final spacing = ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0);
          final horizontalPadding = ResponsiveHelper.responsiveHorizontalPaddingFromConstraints(constraints);

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // Bottom Gradients only
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Image.asset(
                      AppAssets.gradientBottomLeft,
                      width: gradientWidth,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0),
                      child: Image.asset(
                        AppAssets.gradientBottomLeft,
                        width: gradientWidth,
                      ),
                    ),
                  ),

                  // Main Content with max width constraint
                  ResponsiveMaxWidth(
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: EdgeInsets.only(
                            top: spacing,
                            bottom: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 12.0),
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
                                            _buildIconButton(Icons.settings_outlined, AppColors.textPrimary, const Color(0xFFF5F5F5), iconSize, () {}),
                                            _buildIconButton(Icons.notifications_outlined, AppColors.textSecondary, Colors.white, iconSize, () {}),
                                            _buildIconButton(Icons.shopping_cart_outlined, Colors.white, AppColors.primary, iconSize, () {}),
                                          ],
                                        );
                                      }
                                      
                                      return Row(
                                        children: [
                                          // Settings Button
                                          _buildIconButton(Icons.settings_outlined, AppColors.textPrimary, const Color(0xFFF5F5F5), iconSize, () {}),
                                          SizedBox(width: spacing),
                                          // Notifications Button
                                          _buildIconButton(Icons.notifications_outlined, AppColors.textSecondary, Colors.white, iconSize, () {}),
                                          SizedBox(width: spacing),
                                          // Shopping Cart Button
                                          _buildIconButton(Icons.shopping_cart_outlined, Colors.white, AppColors.primary, iconSize, () {}),
                                        ],
                                      );
                                    },
                                  ),
                                  // Search Bar
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: spacing),
                                      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 16.0)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                                      child: TextField(
                                        style: TextStyle(
                                          fontSize: ResponsiveHelper.responsiveFontSize(context, base: 14.0, min: 12.0, max: 16.0),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'نفسك فأيه؟',
                                          hintStyle: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: ResponsiveHelper.responsiveFontSize(context, base: 14.0, min: 12.0, max: 16.0),
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
                                  // Profile Picture
                                  Container(
                                    width: iconSize,
                                    height: iconSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Container(
                            color: Colors.blue.shade100,
                            child: const Icon(
                              Icons.person,
                              color: Colors.blue,
                            ),
                          ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        // Title Section
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 16.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'منزلي',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.responsiveFontSize(context, base: 32.0, min: 24.0, max: 48.0),
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 4.0)),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 4.0),
                                children: [
                                  Text(
                                    'شغل يدوي وأكل بيتي على أصوله',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.responsiveFontSize(context, base: 14.0, min: 12.0, max: 16.0),
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '👋',
                                    style: TextStyle(fontSize: ResponsiveHelper.responsiveFontSize(context, base: 16.0)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Scrollable Content
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 16.0)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(ResponsiveHelper.responsiveValueFromConstraints(constraints, base: 30.0, lg: 32.0)),
                              ),
                            ),
                            child: Consumer<ServicesProvider>(
                              builder: (context, servicesProvider, _) {
                                final featured = servicesProvider.featuredServices;
                                final recommended = servicesProvider.recommendedServices;
                                final allServices = servicesProvider.services;

                                final bool isInitialLoading =
                                    servicesProvider.isLoading &&
                                    featured.isEmpty &&
                                    recommended.isEmpty &&
                                    allServices.isEmpty;

                                if (isInitialLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                return SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // أقوى العروض (Strongest Offers) - uses featured services
                                      if (featured.isNotEmpty)
                                        FoodListSection(
                                          title: 'أقوى العروض',
                                          titleIcon: Icons.percent,
                                          titleIconColor: Colors.red,
                                          foodItems: _buildFoodCardsFromServices(
                                            context,
                                            constraints,
                                            featured,
                                          ),
                                        ),

                                      if (featured.isNotEmpty)
                                        SizedBox(
                                          height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0),
                                        ),

                                      // خدمات مرشحه (Recommended Services)
                                      if (recommended.isNotEmpty)
                                        FoodListSection(
                                          title: 'خدمات مرشحه',
                                          foodItems: _buildFoodCardsFromServices(
                                            context,
                                            constraints,
                                            recommended,
                                            badge: 'مرشحه',
                                          ),
                                        ),

                                      if (recommended.isNotEmpty)
                                        SizedBox(
                                          height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0),
                                        ),

                                      // الأكثر مبيعًا (Bestsellers) - fall back to general services
                                      if (allServices.isNotEmpty)
                                        FoodListSection(
                                          title: 'الأكثر مبيعًا',
                                          titleIcon: Icons.star,
                                          titleIconColor: Colors.amber,
                                          foodItems: _buildFoodCardsFromServices(
                                            context,
                                            constraints,
                                            allServices.take(10).toList(),
                                            badge: 'أفضل',
                                          ),
                                        ),

                                      if (allServices.isNotEmpty)
                                        SizedBox(
                                          height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0),
                                        ),

                                      // الخدمات (Services) - preview of the services list
                                      if (allServices.isNotEmpty)
                                        FoodListSection(
                                          title: 'الخدمات',
                                          viewAllText: 'عرض الكل',
                                          onViewAllTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const ServicesView(),
                                              ),
                                            );
                                          },
                                          onTitleTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const ServicesView(),
                                              ),
                                            );
                                          },
                                          foodItems: _buildFoodCardsFromServices(
                                            context,
                                            constraints,
                                            allServices.take(10).toList(),
                                          ),
                                        ),

                                      SizedBox(
                                        height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 20.0),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavBar(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() {
                  _currentNavIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }

  List<FoodCard> _buildFoodCardsFromServices(
    BuildContext context,
    BoxConstraints constraints,
    List<ServiceItem> services, {
    String? badge,
  }) {
    return services.map((service) {
      // API currently returns only a file name (e.g. "cakes_1.jpg").
      // Build a full HTTP URL using the API base when needed.
      String? imageUrl;
      if (service.imageUrl.isNotEmpty) {
        if (service.imageUrl.startsWith('http')) {
          imageUrl = service.imageUrl;
        } else {
          final base = ApiConstants.baseUrl;
          final normalizedBase = base.endsWith('/') ? base : '$base/';
          imageUrl = '$normalizedBase${service.imageUrl}';
        }
      }

      return FoodCard(
        imagePath: AppAssets.donuts, // fallback asset
        networkImageUrl: imageUrl,
        name: service.title,
        sellerName: service.providerName,
        price: service.basePrice.toDouble(),
        rating: service.rating.toDouble(),
        badge: badge,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailsView(
                serviceId: service.id,
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildIconButton(IconData icon, Color iconColor, Color bgColor, double size, VoidCallback onPressed) {
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
