import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/data/models/order_models.dart';
import 'package:manzili_mobile/data/models/service_models.dart';
import 'package:manzili_mobile/data/repositories/orders_repository.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import '../../core/strings/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/common/service_cover_image.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/widgets/responsive_max_width.dart';
import '../widgets/home/food_card.dart';

class ServiceDetailsView extends StatefulWidget {
  final int serviceId;

  const ServiceDetailsView({super.key, required this.serviceId});

  @override
  State<ServiceDetailsView> createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends State<ServiceDetailsView> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  String? _selectedOptionId;
  bool _isFavorite = false;
  final Map<int, bool> _selectedOptions = {};
  final TextEditingController _notesController = TextEditingController();
  bool _submittingOrder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesProvider>().getServiceById(widget.serviceId);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<OrderOptionGroup> _optionGroupsForRequest(ServiceItem service) {
    final options = service.options ?? [];
    if (options.isEmpty) return [];

    final items = <OrderOptionItem>[];
    if (_selectedOptionId != null) {
      final id = int.tryParse(_selectedOptionId!);
      if (id != null) {
        items.add(OrderOptionItem(optionId: id, quantity: _quantity));
      }
    } else {
      for (final o in options) {
        if (_selectedOptions[o.id] == true) {
          items.add(OrderOptionItem(optionId: o.id, quantity: 1));
        }
      }
    }

    if (items.isEmpty) return [];
    return [OrderOptionGroup(groupId: 1, items: items)];
  }

  Future<void> _submitOrderRequest() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سجّل دخول الأول عشان تطلب الخدمة')),
      );
      context.push('/signin');
      return;
    }

    final servicesProvider = context.read<ServicesProvider>();
    final service = servicesProvider.currentServiceDetails;
    if (service == null || service.id != widget.serviceId) {
      return;
    }

    final options = service.options ?? [];
    if (options.isNotEmpty) {
      final hasRadio = _selectedOptionId != null;
      final hasBox = _selectedOptions.values.any((v) => v);
      if (!hasRadio && !hasBox) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اختار نوع الخدمة أو الإضافة الأول')),
        );
        return;
      }
    }

    setState(() => _submittingOrder = true);
    final body = OrderRequestBody(
      serviceId: widget.serviceId,
      customizationText: _notesController.text.trim(),
      quantity: _quantity,
      optionGroups: _optionGroupsForRequest(service),
    );

    final err = await OrdersRepository().requestService(body);
    if (!mounted) return;
    setState(() => _submittingOrder = false);

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمام! طلبك اتسجل بنجاح')),
      );
      context.push('/order-placed');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
    }
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
                      // Use detailed service if available, otherwise fall back to list
                      ServiceItem? service = servicesProvider.currentServiceDetails;
                      if (service == null || service.id != widget.serviceId) {
                        for (final s in servicesProvider.services) {
                          if (s.id == widget.serviceId) {
                            service = s;
                            break;
                          }
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
                            if (service.options != null && service.options!.isNotEmpty)
                              _buildFlavorSelector(service),
                            _buildQuantitySelector(),
                            _buildSpecialInstructions(),
                            if (service.options != null && service.options!.isNotEmpty)
                              _buildProductsWithOrder(service),
                            _buildSellerInfo(service),
                            _buildYouMightAlsoLike(servicesProvider),
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
                  onPressed: () => context.push('/cart'),
                ),
              ),
            ],
          ),
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            color: AppColors.textPrimary,
            onPressed: () => context.pop(),
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
    
    final rawImagePaths = <String>[];
    if (service.images != null && service.images!.isNotEmpty) {
      for (final img in service.images!) {
        if (img.imageUrl.trim().isNotEmpty) rawImagePaths.add(img.imageUrl);
      }
    } else if (service.imageUrl.trim().isNotEmpty) {
      rawImagePaths.add(service.imageUrl);
    }

    if (_currentImageIndex >= rawImagePaths.length && rawImagePaths.isNotEmpty) {
      _currentImageIndex = 0;
    }

    return Stack(
      children: [
        ServiceCoverImage(
          imageUrlRaw: rawImagePaths.isEmpty ? null : rawImagePaths[_currentImageIndex],
          width: double.infinity,
          height: imageHeight,
          fit: BoxFit.cover,
        ),
        if (rawImagePaths.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(rawImagePaths.length, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _currentImageIndex = index),
                  child: Container(
                    width: index == _currentImageIndex ? 8 : 6,
                    height: index == _currentImageIndex ? 8 : 6,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentImageIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
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
            onTap: () => context.push('/reviews/${widget.serviceId}'),
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

  Widget _buildFlavorSelector(ServiceItem service) {
    final options = service.options ?? [];
    if (options.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر الخيار',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 16),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
          ...options.map((option) {
            final isSelected = _selectedOptionId == option.id.toString();
            return Padding(
              padding: EdgeInsets.only(bottom: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedOptionId = option.id.toString();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16),
                    vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 14),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          option.serviceOptionName,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${option.price.toInt()} جنيه',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
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
                    color: AppColors.surfaceMuted,
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
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: TextField(
              controller: _notesController,
              style: TextStyle(
                fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
              ),
              decoration: InputDecoration(
                hintText: AppStrings.orderNotesHint,
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

  Widget _buildProductsWithOrder(ServiceItem service) {
    final options = service.options ?? [];
    if (options.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22),
        vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'خيارات إضافية',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 18, tablet: 20),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
          ...options.map((option) {
            final isSelected = _selectedOptions[option.id] ?? false;
            return Padding(
              padding: EdgeInsets.only(bottom: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${option.serviceOptionName} - ${option.price.toInt()} جنيه',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        _selectedOptions[option.id] = value ?? false;
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
    final provider = service.provider;
    final providerName = provider?.fullName ?? service.providerName;
    final providerRating = provider?.rating ?? service.rating;
    final reviewsCount = provider?.reviewsNo ?? 0;
    
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
                        providerName,
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
                            providerRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 4)),
                          Icon(Icons.star, color: Colors.amber, size: ResponsiveHelper.responsiveValueCompat(context, mobile: 16.0)),
                          if (reviewsCount > 0) ...[
                            SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 4)),
                            Text(
                              '($reviewsCount) تقييم',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 12),
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
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

  Widget _buildYouMightAlsoLike(ServicesProvider servicesProvider) {
    // Get other services excluding current one
    final otherServices = servicesProvider.services
        .where((s) => s.id != widget.serviceId)
        .take(4)
        .toList();
    
    if (otherServices.isEmpty) return const SizedBox.shrink();
    
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
                  children: otherServices.take(2).map((service) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: service == otherServices.first
                              ? ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)
                              : 0,
                        ),
                        child: FoodCard(
                          networkImageUrl: service.imageUrl,
                          name: service.title,
                          sellerName: service.providerName,
                          price: service.basePrice.toDouble(),
                          rating: service.rating.toDouble(),
                          onTap: () => context.pushReplacement(
                                '/service/${service.id}',
                              ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              } else {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: otherServices.map((service) {
                      return Padding(
                        padding: EdgeInsets.only(
                          left: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12),
                        ),
                        child: FoodCard(
                          networkImageUrl: service.imageUrl,
                          name: service.title,
                          sellerName: service.providerName,
                          price: service.basePrice.toDouble(),
                          rating: service.rating.toDouble(),
                          onTap: () => context.pushReplacement(
                                '/service/${service.id}',
                              ),
                        ),
                      );
                    }).toList(),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.serviceRequestHelper,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 12),
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 10)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submittingOrder ? null : _submitOrderRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveValueCompat(context, mobile: 12.0)),
                      ),
                    ),
                    child: _submittingOrder
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'اطلب الخدمة',
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
                    context.pop();
                  },
                  icon: Icon(
                    Icons.home_outlined,
                    color: AppColors.textSecondary,
                    size: ResponsiveHelper.responsiveValueCompat(context, mobile: 28.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
