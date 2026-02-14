import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/data/models/service_models.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import 'package:manzili_mobile/presentation/views/service_details_view.dart';
import 'package:manzili_mobile/presentation/widgets/services/filter_button.dart';
import 'package:manzili_mobile/presentation/widgets/services/service_grid_card.dart';
import 'package:manzili_mobile/presentation/widgets/services/sort_modal.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/responsive_max_width.dart';

class ServicesView extends StatefulWidget {
  const ServicesView({super.key});

  @override
  State<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<ServicesView> {
  String _selectedFilter = 'اكتشف افضل الخدمات';
  String _selectedSortOption = 'الافتراضي';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesProvider>().fetchServices();
    });
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
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
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
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.search),
                          color: AppColors.textPrimary,
                          onPressed: () {},
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
                          onPressed: () {},
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
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: AppColors.textPrimary,
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
                    color: Colors.grey.shade200,
                  ),
                  ResponsiveMaxWidth(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 12.0),
                      ),
                      child: Row(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'الكل',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),
                      GestureDetector(
                        onTap: () => _showSortModal(context),
                        child: Container(
                          padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Icon(
                            Icons.swap_vert,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                      Container(
                        width: 1,
                        height: ResponsiveHelper.scaleValue(32.0, constraints.maxWidth, min: 28.0, max: 40.0),
                        margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 12.0)),
                        color: Colors.grey.shade300,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterButton(
                                text: 'اكتشف افضل الخدمات',
                                isSelected: _selectedFilter == 'اكتشف افضل الخدمات',
                                onTap: () => setState(() => _selectedFilter = 'اكتشف افضل الخدمات'),
                              ),
                              SizedBox(width: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),
                              FilterButton(
                                text: 'مشغولات يدويه',
                                isSelected: _selectedFilter == 'مشغولات يدويه',
                                onTap: () => setState(() => _selectedFilter = 'مشغولات يدويه'),
                              ),
                              SizedBox(width: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),
                              FilterButton(
                                text: 'أكل بيتي',
                                isSelected: _selectedFilter == 'أكل بيتي',
                                onTap: () => setState(() => _selectedFilter = 'أكل بيتي'),
                              ),
                              SizedBox(width: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),
                              FilterButton(
                                text: 'حلويات',
                                isSelected: _selectedFilter == 'حلويات',
                                onTap: () => setState(() => _selectedFilter = 'حلويات'),
                              ),
                              SizedBox(width: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),
                              FilterButton(
                                text: 'مشروبات',
                                isSelected: _selectedFilter == 'مشروبات',
                                onTap: () => setState(() => _selectedFilter = 'مشروبات'),
                              ),
                            ],
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
                                    servicesProvider.fetchServices();
                                  },
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          );
                        }

                        final List<ServiceItem> services =
                            servicesProvider.services;

                        if (services.isEmpty) {
                          return const Center(
                            child: Text(
                              'لا توجد خدمات متاحة حالياً',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
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
