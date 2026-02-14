import 'package:flutter/material.dart';
import 'package:manzili_mobile/presentation/widgets/home/food_card.dart';
import 'package:manzili_mobile/presentation/widgets/home/food_list_section.dart';
import 'package:manzili_mobile/presentation/widgets/home/bottom_nav_bar.dart';
import 'package:manzili_mobile/presentation/views/services_view.dart';
import '../../../core/constants/app_assets.dart';
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
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // أقوى العروض (Strongest Offers)
                                  FoodListSection(
                            title: 'أقوى العروض',
                            titleIcon: Icons.percent,
                            titleIconColor: Colors.red,
                            foodItems: [
                              FoodCard(
                                imagePath: AppAssets.donuts,
                                name: 'دوناتس',
                                sellerName: 'أمينه حسان',
                                price: 120,
                                originalPrice: 250,
                                rating: 4.8,
                                badge: 'خصم 50%',
                              ),
                              FoodCard(
                                imagePath: AppAssets.cookie,
                                name: 'كوكيز',
                                sellerName: 'سارة محمد',
                                price: 80,
                                originalPrice: 160,
                                rating: 4.9,
                                badge: 'خصم 50%',
                              ),
                            ],
                          ),

                                  SizedBox(height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),

                                  // خدمات مرشحه (Recommended Services)
                                  FoodListSection(
                            title: 'خدمات مرشحه',
                            foodItems: [
                              FoodCard(
                                imagePath: AppAssets.donuts,
                                name: 'دوناتس',
                                sellerName: 'أمينه حسان',
                                price: 120,
                                rating: 4.8,
                                badge: 'مرشحه',
                              ),
                              FoodCard(
                                imagePath: AppAssets.cupcake,
                                name: 'كاب كيك',
                                sellerName: 'ليلى أحمد',
                                price: 150,
                                rating: 4.7,
                                badge: 'مرشحه',
                              ),
                            ],
                          ),

                                  SizedBox(height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),

                                  // الأكثر مبيعًا (Bestsellers)
                                  FoodListSection(
                            title: 'الأكثر مبيعًا',
                            titleIcon: Icons.star,
                            titleIconColor: Colors.amber,
                            foodItems: [
                              FoodCard(
                                imagePath: AppAssets.donuts,
                                name: 'دوناتس',
                                sellerName: 'أمينه حسان',
                                price: 120,
                                rating: 4.8,
                                badge: 'أفضل',
                              ),
                              FoodCard(
                                imagePath: AppAssets.kunafa,
                                name: 'كنافة',
                                sellerName: 'فاطمة علي',
                                price: 200,
                                rating: 5.0,
                                badge: 'أفضل',
                              ),
                            ],
                          ),

                                  SizedBox(height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),

                                  // الخدمات (Services)
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
                            foodItems: [
                              FoodCard(
                                imagePath: AppAssets.cupcake,
                                name: 'كاب كيك',
                                sellerName: 'ليلى أحمد',
                                price: 150,
                                rating: 4.7,
                                badge: 'مرشحه',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ServicesView(),
                                    ),
                                  );
                                },
                              ),
                              FoodCard(
                                imagePath: AppAssets.strawberryCake,
                                name: 'كيكة بالفراولة',
                                sellerName: 'نورا خالد',
                                price: 180,
                                rating: 4.6,
                                badge: 'أفضل',
                              ),
                              FoodCard(
                                imagePath: AppAssets.kunafa,
                                name: 'كنافة',
                                sellerName: 'فاطمة علي',
                                price: 200,
                                rating: 5.0,
                              ),
                            ],
                          ),

                                  SizedBox(height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 20.0)),
                                ],
                              ),
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
