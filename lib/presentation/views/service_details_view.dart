import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/data/models/service_models.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/widgets/responsive_max_width.dart';
import '../widgets/home/food_card.dart';
import 'reviews_view.dart';

class ServiceDetailsView extends StatefulWidget {
  final int serviceId;

  const ServiceDetailsView({super.key, required this.serviceId});

  @override
  State<ServiceDetailsView> createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends State<ServiceDetailsView> {
  int _currentImageIndex = 1;
  int _quantity = 1;
  String _selectedFlavor = 'فانيليا';
  bool _isFavorite = false;
  final Map<String, bool> _selectedProducts = {
    'كوكيز شوكولاته': false,
    'سينابون رول': false,
    'دوناتس': false,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesProvider>().getServiceById(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final headerHeight = MediaQuery.of(context).padding.top + ResponsiveHelper.responsiveValueCompat(context, mobile: 60.0, tablet: 64.0);
          
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: headerHeight,
                  child: _buildHeader(),
                ),
                Positioned(
                  top: headerHeight,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Consumer<ServicesProvider>(
                    builder: (context, servicesProvider, _) {
                  ServiceItem? service;
                  for (final s in servicesProvider.services) {
                    if (s.id == widget.serviceId) {
                      service = s;
                      break;
                    }
                  }

                  if (servicesProvider.isLoading && service == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (servicesProvider.errorMessage != null &&
                      service == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              servicesProvider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              servicesProvider
                                  .getServiceById(widget.serviceId);
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (service == null) {
                    return const Center(
                      child: Text(
                        'لم يتم العثور على هذه الخدمة',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                      return ResponsiveMaxWidth(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + ResponsiveHelper.responsiveSpacingCompat(context, mobile: 100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            _buildProductImage(service),
                            _buildProductInfo(service),
                            _buildFlavorSelector(),
                            _buildQuantitySelector(),
                            _buildSpecialInstructions(),
                            _buildProductsWithOrder(),
                            _buildSellerInfo(service),
                            _buildYouMightAlsoLike(),
                          ],
                        ),
                      ),
                    );
                    },
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          );
      },
    ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8),
        left: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16),
        right: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16),
        bottom: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12),
      ),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0, tablet: 44.0),
                height: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0, tablet: 44.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.share_outlined),
                  color: AppColors.textPrimary,
                  onPressed: () {},
                ),
              ),
              SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
              Container(
                width: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0, tablet: 44.0),
                height: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0, tablet: 44.0),
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
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(ServiceItem service) {
    final imageHeight = ResponsiveHelper.clampScaledValue(
      context,
      40,
      min: 250.0,
      max: 400.0,
    );
    
    return Stack(
      children: [
        service.imageUrl.isNotEmpty
            ? Image.network(
                service.imageUrl,
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.cover,
              )
            : Image.asset(
                AppAssets.cookie,
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.cover,
              ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                width: index == _currentImageIndex ? 8 : 6,
                height: index == _currentImageIndex ? 8 : 6,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentImageIndex
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(ServiceItem service) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.title,
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 24, tablet: 26, desktop: 28),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReviewsView(),
                ),
              );
            },
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  '(تقييم الخدمة)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  service.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
                ...List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: ResponsiveHelper.responsiveValueCompat(context, mobile: 18.0),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
          Text(
            '${service.basePrice} جنيه',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 28, tablet: 30, desktop: 32),
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'متاح في: ',
                style: TextStyle(
                  fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
          Text(
            'الوقت المستغرق في التحضير: ساعتين',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
          GestureDetector(
            onTap: () {},
            child: Text(
              'حول هذة الخدمة',
              style: TextStyle(
                fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                fontWeight: FontWeight.w600,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlavorSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر النكهة',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 16),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16),
                vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 14),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                  Text(
                    _selectedFlavor,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22),
        vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الكمية',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 16),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_quantity > 1) {
                    setState(() => _quantity--);
                  }
                },
                child: Container(
                  width: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0),
                  height: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.remove, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 24)),
              Text(
                '$_quantity',
                style: TextStyle(
                  fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 20),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 24)),
              GestureDetector(
                onTap: () {
                  setState(() => _quantity++);
                },
                child: Container(
                  width: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0),
                  height: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialInstructions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تعليمات خاصة (اختياري)',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 16),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: TextField(
              style: TextStyle(
                fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
              ),
              decoration: InputDecoration(
                hintText: 'أضف أي طلبات خاصة.....',
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                ),
                border: InputBorder.none,
              ),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsWithOrder() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22),
        vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'منتجات مع الطلب',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 18, tablet: 20),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
          ..._selectedProducts.keys.map((product) {
            return Padding(
              padding: EdgeInsets.only(bottom: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '$product - 120 جنيه',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Checkbox(
                    value: _selectedProducts[product],
                    onChanged: (value) {
                      setState(() {
                        _selectedProducts[product] = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSellerInfo(ServiceItem service) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22),
        vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'يباع بواسطة',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 18, tablet: 20),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: ResponsiveHelper.responsiveValueCompat(context, mobile: 50.0, tablet: 56.0),
                  height: ResponsiveHelper.responsiveValueCompat(context, mobile: 50.0, tablet: 56.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.providerName,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 16),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 4)),
                      Row(
                        children: [
                          Text(
                            '4.9',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 4)),
                          Icon(Icons.star, color: Colors.amber, size: ResponsiveHelper.responsiveValueCompat(context, mobile: 16.0)),
                          SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 4)),
                          Text(
                            '(284) تقييم',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 12),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouMightAlsoLike() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22),
        vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'قد يعجبك ايضاً',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 18, tablet: 20),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
          LayoutBuilder(
            builder: (context, constraints) {
                      final crossAxisCount = ResponsiveHelper.gridColumnCount(
                        context,
                        xs: 1,
                        sm: 2,
                        md: 3,
                        lg: 4,
                        xl: 5,
                      );
              
              if (crossAxisCount >= 2) {
                return Row(
                  children: [
                    Expanded(
                      child: FoodCard(
                        imagePath: AppAssets.strawberryCake,
                        name: 'كيكة بالفراولة',
                        sellerName: 'ليلى أحمد',
                        price: 120,
                        rating: 4.8,
                        badge: 'مرشحه',
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
                    Expanded(
                      child: FoodCard(
                        imagePath: AppAssets.cookie,
                        name: 'كيكة بالفراولة',
                        sellerName: 'ليلى أحمد',
                        price: 120,
                        rating: 4.8,
                      ),
                    ),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FoodCard(
                        imagePath: AppAssets.strawberryCake,
                        name: 'كيكة بالفراولة',
                        sellerName: 'ليلى أحمد',
                        price: 120,
                        rating: 4.8,
                        badge: 'مرشحه',
                      ),
                      SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
                      FoodCard(
                        imagePath: AppAssets.cookie,
                        name: 'كيكة بالفراولة',
                        sellerName: 'ليلى أحمد',
                        price: 120,
                        rating: 4.8,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16),
          right: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16),
          top: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16),
          bottom: MediaQuery.of(context).padding.bottom + ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveValueCompat(context, mobile: 12.0)),
                  ),
                ),
                child: Text(
                  'أضف الي عربة التسوق',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 16),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
            IconButton(
              onPressed: () {
                setState(() => _isFavorite = !_isFavorite);
              },
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : AppColors.textSecondary,
                size: ResponsiveHelper.responsiveValueCompat(context, mobile: 28.0),
              ),
            ),
            SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.home_outlined,
                color: AppColors.textSecondary,
                size: ResponsiveHelper.responsiveValueCompat(context, mobile: 28.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
