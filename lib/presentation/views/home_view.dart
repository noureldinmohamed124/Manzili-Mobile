import 'package:flutter/material.dart';
import 'package:manzili_mobile/presentation/widgets/home/food_card.dart';
import 'package:manzili_mobile/presentation/widgets/home/food_list_section.dart';
import 'package:manzili_mobile/presentation/widgets/home/bottom_nav_bar.dart';
import 'package:manzili_mobile/presentation/views/services_view.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Bottom Gradients only
            Positioned(
              bottom: 0,
              left: 0,
              child: Image.asset(
                AppAssets.gradientBottomLeft,
                width: size.width * 0.45,
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
                  width: size.width * 0.45,
                ),
              ),
            ),

            // Main Content
            Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      // Left Icons
                      Row(
                        children: [
                          // Settings Button
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.settings_outlined),
                              color: AppColors.textPrimary,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Notifications Button
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.notifications_outlined),
                              color: AppColors.textSecondary,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Shopping Cart Button
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.shopping_cart_outlined),
                              color: Colors.white,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      // Search Bar
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            decoration: const InputDecoration(
                              hintText: 'نفسك فأيه؟',
                              hintStyle: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 14,
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
                      // Profile Picture
                      Container(
                        width: 40,
                        height: 40,
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
                  ),
                ),

                // Title Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                  child: Column(
                    children: [
                      const Text(
                        'منزلي',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'شغل يدوي وأكل بيتي على أصوله',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('👋', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
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

                          const SizedBox(height: 8),

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

                          const SizedBox(height: 8),

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

                          const SizedBox(height: 8),

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

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            setState(() {
              _currentNavIndex = index;
            });
          },
        ),
      ),
    );
  }
}
