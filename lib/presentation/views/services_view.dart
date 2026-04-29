import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/data/models/service_models.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import 'package:manzili_mobile/presentation/widgets/services/filter_button.dart';
import 'package:manzili_mobile/presentation/widgets/services/service_grid_card.dart';
import 'package:manzili_mobile/presentation/widgets/services/sort_modal.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/responsive_max_width.dart';

class ServicesView extends StatefulWidget {
  const ServicesView({super.key});

  @override
  State<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<ServicesView> {
  int? _selectedCategoryId;
  bool _sortAscending = true;
  String _selectedSortOption = 'الافتراضي';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final q = GoRouter.of(context).state.uri.queryParameters['q'] ?? '';
      final catId = GoRouter.of(context).state.uri.queryParameters['categoryId'];
      setState(() {
        _searchQuery = q;
        if (catId != null) {
          _selectedCategoryId = int.tryParse(catId);
        }
      });
      final provider = context.read<ServicesProvider>();
      if (provider.categories.isEmpty) {
        provider.fetchCategories();
      }
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    await context.read<ServicesProvider>().fetchServices(
      page: 1, 
      pageSize: 50,
      searchQuery: _searchQuery,
      categoryId: _selectedCategoryId,
    );
  }

  void _openSearchDialog() {
    final controller = TextEditingController(text: _searchQuery);
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(AppStrings.servicesSearchDialogTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: AppStrings.servicesSearchFieldHint,
            ),
            onSubmitted: (v) {
              setState(() => _searchQuery = v.trim());
              Navigator.of(ctx).pop();
              _fetchData();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => _searchQuery = controller.text.trim());
                Navigator.of(ctx).pop();
                _fetchData();
              },
              child: const Text(AppStrings.servicesSearchAction),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortModal(
        selectedOption: _selectedSortOption,
        onOptionSelected: (option) {
          setState(() {
            _selectedSortOption = option;
            if (option == 'من الأقل') {
              _sortAscending = true;
            } else if (option == 'من الأعلى') {
              _sortAscending = false;
            } else {
              _sortAscending = true; // Default
            }
          });
          context.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  ResponsiveMaxWidth(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0),
                        bottom: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 12.0),
                      ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      Container(
                        width: ResponsiveHelper.scaleValue(40.0, constraints.maxWidth, min: 36.0, max: 48.0),
                        height: ResponsiveHelper.scaleValue(40.0, constraints.maxWidth, min: 36.0, max: 48.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.search),
                          color: Theme.of(context).iconTheme.color ?? AppColors.textPrimary,
                          onPressed: _openSearchDialog,
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),
                      Container(
                        width: ResponsiveHelper.scaleValue(40.0, constraints.maxWidth, min: 36.0, max: 48.0),
                        height: ResponsiveHelper.scaleValue(40.0, constraints.maxWidth, min: 36.0, max: 48.0),
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
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                          Text(
                            'الخدمات',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.responsiveFontSize(context, base: 20.0, min: 18.0, max: 24.0),
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).textTheme.displayLarge?.color ?? AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Theme.of(context).iconTheme.color ?? AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
                  ),
                  Container(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  ResponsiveMaxWidth(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 12.0),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                        onTap: () => _showSortModal(context),
                        child: Container(
                          padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.swap_vert,
                                size: 20,
                                color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ترتيب',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 12.0)),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Consumer<ServicesProvider>(
                            builder: (context, provider, _) {
                              final categories = provider.categories;
                              if (categories.isEmpty && provider.isLoading) {
                                return const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                              }
                              return Row(
                                children: [
                                  FilterButton(
                                    text: 'الكل',
                                    isSelected: _selectedCategoryId == null,
                                    onTap: () {
                                      setState(() => _selectedCategoryId = null);
                                      _fetchData();
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ...categories.map((cat) => Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: FilterButton(
                                      text: cat.nameAr,
                                      isSelected: _selectedCategoryId == cat.id,
                                      onTap: () {
                                        setState(() => _selectedCategoryId = cat.id);
                                        _fetchData();
                                      },
                                    ),
                                  )),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                    ),
                  ),
                  Expanded(
                    child: Consumer<ServicesProvider>(
                      builder: (context, servicesProvider, _) {
                        if (servicesProvider.isLoading &&
                            servicesProvider.services.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (servicesProvider.errorMessage != null &&
                            servicesProvider.services.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                                    servicesProvider.fetchServices(page: 1, pageSize: 50);
                                  },
                                  child: const Text('جرّب تاني'),
                                ),
                              ],
                            ),
                          );
                        }

                        List<ServiceItem> services = _searchQuery.isEmpty
                            ? List.from(servicesProvider.services)
                            : servicesProvider.filterServicesLocally(_searchQuery);

                        services.sort((a, b) => _sortAscending 
                            ? a.basePrice.compareTo(b.basePrice) 
                            : b.basePrice.compareTo(a.basePrice));

                        if (services.isEmpty) {
                          return Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'مفيش خدمات دلوقتي، جرّب تاني بعدين'
                                  : 'مفيش نتيجة للبحث "$_searchQuery"',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        // Use outer constraints to avoid nested LayoutBuilder issues
                        // Calculate optimal columns based on available width
                        final itemMinWidth = 160.0;
                        final gridSpacing = ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 12.0);
                        final effectiveW = ResponsiveHelper.effectiveWidthFromConstraints(constraints);
                        final availableWidth = effectiveW - (gridSpacing * 2);
                        final crossAxisCount = ResponsiveHelper.calculateGridColumns(
                          availableWidth: availableWidth,
                          itemMinWidth: itemMinWidth,
                          spacing: gridSpacing,
                        );
                        
                        // Use size class based columns
                        final sizeClassColumns = ResponsiveHelper.gridColumnCountFromConstraints(
                          constraints,
                          xs: 1,
                          sm: 2,
                          md: 3,
                          lg: 4,
                          xl: 6, // Allow more columns on ultra-wide screens
                        );
                        
                        // Use the larger of calculated or size class columns, but cap at 6 for readability
                        final finalColumns = (crossAxisCount > sizeClassColumns ? crossAxisCount : sizeClassColumns).clamp(1, 6);
                        
                        // Calculate safe aspect ratio that works on all widths
                        final aspectRatio = ResponsiveHelper.responsiveValueFromConstraints(
                          constraints,
                          base: 0.75,
                          md: 0.8,
                          lg: 0.85,
                          xl: 0.9,
                        );

                        return ResponsiveMaxWidth(
                          child: SingleChildScrollView(
                            padding: ResponsiveHelper.responsivePaddingFromConstraints(constraints),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: finalColumns,
                                childAspectRatio: aspectRatio,
                                crossAxisSpacing: gridSpacing,
                                mainAxisSpacing: gridSpacing,
                              ),
                              itemCount: services.length,
                              itemBuilder: (context, index) {
                                final service = services[index];
                                return GestureDetector(
                                  onTap: () =>
                                      context.push('/service/${service.id}'),
                                  child: ServiceGridCard(service: service),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
