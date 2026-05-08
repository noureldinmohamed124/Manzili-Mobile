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
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Consumer<ServicesProvider>(
          builder: (context, servicesProvider, _) {
            ServiceItem? service = servicesProvider.currentServiceDetails;
            if (service == null || service.id != widget.serviceId) {
              for (final s in servicesProvider.services) {
                if (s.id == widget.serviceId) { service = s; break; }
              }
            }

            if (servicesProvider.isLoading && service == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (servicesProvider.errorMessage != null && service == null) {
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
                        child: const Icon(Icons.wifi_off_rounded,
                            size: 48, color: AppColors.error),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        servicesProvider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () =>
                            servicesProvider.getServiceById(widget.serviceId),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
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

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image with overlaid back/cart buttons
                      _buildProductImageWithOverlay(service),
                      const SizedBox(height: 4),
                      _buildProductInfo(service),
                      _buildOptionGroups(service),
                      _buildQuantitySelector(),
                      _buildSpecialInstructions(),
                      _buildSellerInfo(service),
                      _buildYouMightAlsoLike(servicesProvider),
                    ],
                  ),
                ),
                _buildBottomBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Image section with floating back/cart/share buttons overlaid on top.
  Widget _buildProductImageWithOverlay(ServiceItem service) {
    final imageHeight = ResponsiveHelper.scaleValue(
      45,
      MediaQuery.of(context).size.width,
      min: 260.0,
      max: 420.0,
    );
    final topPad = MediaQuery.of(context).padding.top;

    final rawImagePaths = <String>[];
    if (service.images != null && service.images!.isNotEmpty) {
      for (final img in service.images!) {
        if (img.imageUrl.trim().isNotEmpty) rawImagePaths.add(img.imageUrl);
      }
    } else if (service.imageUrl.trim().isNotEmpty) {
      rawImagePaths.add(service.imageUrl);
    }

    if (_currentImageIndex >= rawImagePaths.length &&
        rawImagePaths.isNotEmpty) {
      _currentImageIndex = 0;
    }

    return SizedBox(
      height: imageHeight + topPad,
      child: Stack(
        children: [
          // Full-bleed image
          Positioned.fill(
            child: rawImagePaths.isEmpty
                ? Container(
                    color: AppColors.surfaceMuted,
                    child: const Icon(Icons.image_not_supported_outlined,
                        size: 64, color: AppColors.textHint),
                  )
                : PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) =>
                        setState(() => _currentImageIndex = i),
                    itemCount: rawImagePaths.length,
                    itemBuilder: (context, i) => ServiceCoverImage(
                      imageUrlRaw: rawImagePaths[i],
                      width: double.infinity,
                      height: imageHeight + topPad,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),

          // Gradient overlay at top for button legibility
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPad + 70,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Gradient overlay at bottom for price legibility
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Top buttons
          Positioned(
            top: topPad + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _OverlayButton(
                  icon: Icons.arrow_forward_rounded,
                  onTap: () => context.pop(),
                ),
                const Spacer(),
                _OverlayButton(
                  icon: Icons.share_outlined,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _OverlayButton(
                  icon: Icons.shopping_cart_outlined,
                  onTap: () => context.push('/cart'),
                  filled: true,
                ),
              ],
            ),
          ),

          // Page indicator
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
                    dotHeight: 7,
                    dotWidth: 7,
                    expansionFactor: 3,
                  ),
                  onDotClicked: (i) => _pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ),
        ],
      ),
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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.serviceRequestHelper,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Add to cart
                Expanded(
                  child: FilledButton(
                    onPressed: _submittingOrder ? null : _addToCart,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'أضف للسلة',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Buy now
                Expanded(
                  child: FilledButton(
                    onPressed: _submittingOrder ? null : _buyNow,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _submittingOrder
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'اشتري دلوقتي',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                // Favourite
                GestureDetector(
                  onTap: () {
                    final fav = context.read<FavouritesProvider>();
                    final sp = context.read<ServicesProvider>();
                    final s = sp.currentServiceDetails;
                    if (s != null && s.id == widget.serviceId) {
                      fav.toggle(s);
                      setState(() =>
                          _isFavorite = fav.isFavourite(widget.serviceId));
                    } else {
                      setState(() => _isFavorite = !_isFavorite);
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isFavorite
                          ? Colors.red.withValues(alpha: 0.1)
                          : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isFavorite
                            ? Colors.red.withValues(alpha: 0.3)
                            : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? Colors.red : AppColors.textSecondary,
                      size: 24,
                    ),
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

// ── Overlay button (used on top of the hero image) ────────────────────────────

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: filled
              ? AppColors.primary
              : Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
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
