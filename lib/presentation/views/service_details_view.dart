import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/data/models/order_models.dart';
import 'package:manzili_mobile/data/models/service_models.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/providers/cart_provider.dart';
import 'package:manzili_mobile/presentation/providers/favourites_provider.dart';
import 'package:manzili_mobile/presentation/providers/orders_provider.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import '../../core/strings/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/common/service_cover_image.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/widgets/responsive_max_width.dart';
import '../widgets/home/food_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ServiceDetailsView extends StatefulWidget {
  final int serviceId;

  const ServiceDetailsView({super.key, required this.serviceId});

  @override
  State<ServiceDetailsView> createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends State<ServiceDetailsView> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  final TextEditingController _notesController = TextEditingController();
  final PageController _pageController = PageController();
  bool _submittingOrder = false;

  // Per-group selection state.
  // Key = groupId, Value = selected optionId (required groups) or Set<int> (optional groups).
  final Map<int, int?> _radioSelections = {};       // required groups
  final Map<int, Set<int>> _checkboxSelections = {}; // optional groups

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesProvider>().getServiceById(widget.serviceId);
      _isFavorite = context.read<FavouritesProvider>().isFavourite(widget.serviceId);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ── Option helpers ─────────────────────────────────────────────────────────

  List<OrderOptionGroup> _buildOptionGroupsForRequest(ServiceItem service) {
    final groups = service.optionGroups ?? [];
    final result = <OrderOptionGroup>[];
    for (final g in groups) {
      final items = <OrderOptionItem>[];
      if (g.isRequired) {
        final sel = _radioSelections[g.id];
        if (sel != null) items.add(OrderOptionItem(optionId: sel, quantity: 1));
      } else {
        final sel = _checkboxSelections[g.id] ?? {};
        for (final id in sel) {
          items.add(OrderOptionItem(optionId: id, quantity: 1));
        }
      }
      if (items.isNotEmpty) {
        result.add(OrderOptionGroup(groupId: g.id, items: items));
      }
    }
    return result;
  }

  double _calculateTotalPrice(ServiceItem service) {
    double total = service.basePrice.toDouble();
    final groups = service.optionGroups ?? [];
    for (final g in groups) {
      if (g.isRequired) {
        final sel = _radioSelections[g.id];
        if (sel != null) {
          final opt = g.options.where((o) => o.id == sel).firstOrNull;
          if (opt != null) total += opt.price;
        }
      } else {
        final sel = _checkboxSelections[g.id] ?? {};
        for (final id in sel) {
          final opt = g.options.where((o) => o.id == id).firstOrNull;
          if (opt != null) total += opt.price;
        }
      }
    }
    return total * _quantity;
  }

  bool _validateSelections(ServiceItem service) {
    final groups = service.optionGroups ?? [];
    for (final g in groups) {
      if (g.isRequired && (_radioSelections[g.id] == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('اختار خيار من "${g.name}" الأول')),
        );
        return false;
      }
    }
    return true;
  }

  CartItem _buildCartItem(ServiceItem service) {
    final totalPrice = _calculateTotalPrice(service);
    return CartItem(
      serviceId: service.id,
      title: service.title,
      providerName: service.providerName,
      imageUrl: service.imageUrl,
      quantity: _quantity,
      pricePerItem: totalPrice / _quantity,
      customizationText: _notesController.text.trim(),
      optionGroups: _buildOptionGroupsForRequest(service),
    );
  }

  Future<void> _addToCart() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سجّل دخول الأول عشان تطلب الخدمة')),
      );
      context.push('/signin');
      return;
    }
    final service = _currentService();
    if (service == null) return;
    if (!_validateSelections(service)) return;
    context.read<CartProvider>().addToCart(_buildCartItem(service));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('اتضافت للسلة 👌')),
    );
  }

  /// "اشتري دلوقتي" — submits the order directly then shows payment proof sheet.
  Future<void> _buyNow() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سجّل دخول الأول عشان تطلب الخدمة')),
      );
      context.push('/signin');
      return;
    }
    final service = _currentService();
    if (service == null) return;
    if (!_validateSelections(service)) return;

    setState(() => _submittingOrder = true);
    final cartItem = _buildCartItem(service);
    final body = OrderRequestBody(
      serviceId: cartItem.serviceId,
      customizationText: cartItem.customizationText,
      quantity: cartItem.quantity,
      optionGroups: cartItem.optionGroups,
    );
    final (orderId, err) = await context.read<OrdersProvider>().requestServiceDirect(body);
    setState(() => _submittingOrder = false);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    // Show payment proof bottom sheet, passing the new order ID if we got one
    _showPaymentProofSheet(orderId: orderId);
  }

  void _showPaymentProofSheet({int? orderId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PaymentProofSheet(
        // Pass the order ID if available; the sheet will use it directly.
        // If null, the sheet will fetch the payment summary to find pending orders.
        orderIds: orderId != null ? [orderId] : null,
        onDone: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال الطلب وإثبات الدفع ✅')),
          );
          context.go('/my-orders');
        },
      ),
    );
  }

  ServiceItem? _currentService() {
    final sp = context.read<ServicesProvider>();
    ServiceItem? service = sp.currentServiceDetails;
    if (service == null || service.id != widget.serviceId) {
      for (final s in sp.services) {
        if (s.id == widget.serviceId) { service = s; break; }
      }
    }
    if (service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تفاصيل الخدمة لسه بتحمل، حاول تاني بعد شوية')),
      );
    }
    return service;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final headerHeight = MediaQuery.of(context).padding.top + ResponsiveHelper.responsiveValueCompat(context, mobile: 60.0, tablet: 64.0);
          
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                            _buildOptionGroups(service),
                            _buildQuantitySelector(),
                            _buildSpecialInstructions(),
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
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0, tablet: 44.0),
                height: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0, tablet: 44.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
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
                  color: Theme.of(context).colorScheme.surface,
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
    final imageHeight = ResponsiveHelper.scaleValue(
      40,
      MediaQuery.of(context).size.width,
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
        SizedBox(
          height: imageHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentImageIndex = index),
            itemCount: rawImagePaths.isEmpty ? 1 : rawImagePaths.length,
            itemBuilder: (context, index) {
              return ServiceCoverImage(
                imageUrlRaw: rawImagePaths.isEmpty ? null : rawImagePaths[index],
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.contain,
              );
            },
          ),
        ),
        if (rawImagePaths.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _currentImageIndex,
                count: rawImagePaths.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white.withValues(alpha: 0.5),
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                ),
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
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
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  '(تقييم الخدمة)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  service.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
                ...List.generate(5, (i) {
                    final filled = i < service.rating.floor();
                    final half = !filled && i < service.rating;
                    return Icon(
                      half ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
                      color: Colors.amber,
                      size: ResponsiveHelper.responsiveValueCompat(context, mobile: 18.0),
                    );
                  }),
              ],
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
          Text(
            '${_calculateTotalPrice(service)} جنيه',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 28, tablet: 30, desktop: 32),
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
          if (service.serviceDescription != null && service.serviceDescription!.isNotEmpty)
            Text(
              service.serviceDescription!,
              style: TextStyle(
                fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  /// Renders all option groups from the API.
  /// Required groups (isRequired=true) → radio buttons (must pick one).
  /// Optional groups (isRequired=false) → checkboxes (pick any).
  Widget _buildOptionGroups(ServiceItem service) {
    final groups = service.optionGroups;
    if (groups == null || groups.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22),
          vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'لا توجد خيارات إضافية لهذه الخدمة',
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groups.map((group) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.name,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 16),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (group.isRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'مطلوب',
                          style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w700),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.statusActive.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'اختياري',
                          style: TextStyle(fontSize: 11, color: AppColors.statusActive, fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                ...group.options.map((option) {
                  if (group.isRequired) {
                    // Radio — pick exactly one
                    final isSelected = _radioSelections[group.id] == option.id;
                    return GestureDetector(
                      onTap: () => setState(() => _radioSelections[group.id] = option.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
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
                            if (option.price > 0)
                              Text(
                                '+${option.price.toInt()} جنيه',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Checkbox — pick any
                    final selected = _checkboxSelections[group.id] ?? {};
                    final isChecked = selected.contains(option.id);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          final s = _checkboxSelections[group.id] ?? <int>{};
                          if (isChecked) { s.remove(option.id); } else { s.add(option.id); }
                          _checkboxSelections[group.id] = s;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isChecked ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isChecked ? AppColors.primary : const Color(0xFFE0E0E0),
                            width: isChecked ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                              color: isChecked ? AppColors.primary : AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
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
                            if (option.price > 0)
                              Text(
                                '+${option.price.toInt()} جنيه',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                }),
              ],
            ),
          );
        }).toList(),
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
                  if (_quantity < 10) {
                    setState(() => _quantity++);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('أقصى كمية للطلب هي 10')),
                    );
                  }
                },
                child: Container(
                  width: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0),
                  height: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
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
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                    color: Color(0x26DD643C), // AppColors.primary.withValues(alpha: 0.15)
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary,
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
                          onTap: () => context.push(
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
                          onTap: () => context.push(
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
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
                // Add to cart
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submittingOrder ? null : _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'أضف للسلة',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 10)),
                // Buy now
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submittingOrder ? null : _buyNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _submittingOrder
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text(
                            'اشتري دلوقتي',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
                // Favourite
                IconButton(
                  onPressed: () {
                    final fav = context.read<FavouritesProvider>();
                    final sp = context.read<ServicesProvider>();
                    final s = sp.currentServiceDetails;
                    if (s != null && s.id == widget.serviceId) {
                      fav.toggle(s);
                      setState(() => _isFavorite = fav.isFavourite(widget.serviceId));
                    } else {
                      setState(() => _isFavorite = !_isFavorite);
                    }
                  },
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : AppColors.textSecondary,
                    size: 28,
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

// ── Payment Proof Bottom Sheet ────────────────────────────────────────────────

class _PaymentProofSheet extends StatefulWidget {
  const _PaymentProofSheet({required this.onDone, this.orderIds});
  final VoidCallback onDone;
  /// Order IDs to submit proof for. If null, the sheet fetches the payment
  /// summary to discover pending orders automatically.
  final List<int>? orderIds;

  @override
  State<_PaymentProofSheet> createState() => _PaymentProofSheetState();
}

class _PaymentProofSheetState extends State<_PaymentProofSheet> {
  XFile? _receipt;
  final _notes = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_receipt == null) {
      setState(() => _error = 'ارفع صورة الإيصال الأول');
      return;
    }
    setState(() { _submitting = true; _error = null; });

    List<int>? ids = widget.orderIds;

    // If no IDs were passed, fetch the payment summary to find pending orders.
    if (ids == null || ids.isEmpty) {
      final provider = context.read<OrdersProvider>();
      await provider.fetchPaymentSummary();
      if (!mounted) return;
      final summary = provider.paymentSummary;
      if (summary == null || summary.services.isEmpty) {
        setState(() {
          _submitting = false;
          _error = 'مش لاقي طلبات بانتظار الدفع. جرّب تاني بعد شوية.';
        });
        return;
      }
      ids = summary.services.map((s) => s.orderId).where((id) => id > 0).toList();
    }

    final ok = await context.read<OrdersProvider>().submitPaymentProof(
      targetOrderIds: ids,
      paymentScreenshotPath: _receipt!.path,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      widget.onDone();
    } else {
      setState(() => _error = context.read<OrdersProvider>().errorMessage ?? 'فشل إرسال الإيصال');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'إرسال إثبات الدفع',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'حوّل المبلغ على manzili@instapay ثم ارفع صورة الإيصال',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
            ),
          GestureDetector(
            onTap: () async {
              final f = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (f != null) setState(() => _receipt = f);
            },
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _receipt != null ? AppColors.primary : AppColors.border,
                  width: _receipt != null ? 2 : 1,
                ),
              ),
              child: _receipt != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.statusActive),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _receipt!.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.statusActive),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, size: 32, color: AppColors.textSecondary),
                        SizedBox(height: 8),
                        Text('اضغط لاختيار صورة الإيصال', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(
              labelText: 'ملاحظات (اختياري)',
              hintText: 'أي تفاصيل زيادة…',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('إرسال إثبات الدفع'),
          ),
        ],
      ),
    );
  }
}
