import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/data/models/service_models.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import 'package:manzili_mobile/presentation/widgets/services/service_grid_card.dart';
import 'package:manzili_mobile/presentation/widgets/services/sort_modal.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import 'package:manzili_mobile/l10n/app_localizations.dart';

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
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final q = GoRouter.of(context).state.uri.queryParameters['q'] ?? '';
      final catId = GoRouter.of(context).state.uri.queryParameters['categoryId'];
      setState(() {
        _searchQuery = q;
        _searchController.text = q;
        if (catId != null) _selectedCategoryId = int.tryParse(catId);
      });
      final provider = context.read<ServicesProvider>();
      if (provider.categories.isEmpty) provider.fetchCategories();
      _fetchData();
    });
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final q = _searchController.text.trim();
      if (q == _searchQuery) return;
      setState(() => _searchQuery = q);
      _fetchData();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    await context.read<ServicesProvider>().fetchServices(
      page: 1,
      pageSize: 50,
      searchQuery: _searchQuery,
      categoryId: _selectedCategoryId,
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SortModal(
        selectedOption: _selectedSortOption,
        onOptionSelected: (option) {
          setState(() {
            _selectedSortOption = option;
            _sortAscending = option != 'من الأعلى';
          });
          ctx.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // ── Gradient header ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [const Color(0xFF2A1A14), const Color(0xFF1A1A1A)]
                      : [AppColors.primary, AppColors.secondary],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      // Top row: back + title + cart
                      Row(
                        children: [
                          _GlassButton(
                            icon: Icons.arrow_forward_rounded,
                            onTap: () => context.pop(),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'الخدمات',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          _GlassButton(
                            icon: Icons.shopping_cart_outlined,
                            onTap: () => context.push('/cart'),
                            filled: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Search bar
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          // Live search via _onSearchChanged listener (350ms debounce)
                          decoration: InputDecoration(
                            hintText: AppStrings.servicesSearchFieldHint,
                            hintStyle: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded,
                                        size: 18, color: AppColors.textHint),
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _searchController.clear();
                                      });
                                      _fetchData();
                                    },
                                  )
                                : null,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Filter bar ───────────────────────────────────────────────
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Sort button
                  GestureDetector(
                    onTap: _showSortModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedSortOption != 'الافتراضي'
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedSortOption != 'الافتراضي'
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            size: 18,
                            color: _selectedSortOption != 'الافتراضي'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ترتيب',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _selectedSortOption != 'الافتراضي'
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Category chips
                  Expanded(
                    child: Consumer<ServicesProvider>(
                      builder: (context, sp, _) {
                        final cats = sp.categories;
                        if (cats.isEmpty && sp.isLoading) {
                          return const SizedBox(
                            height: 34,
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }
                        return SizedBox(
                          height: 34,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: cats.length + 1,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 6),
                            itemBuilder: (context, i) {
                              final isAll = i == 0;
                              final label =
                                  isAll ? 'الكل' : cats[i - 1].nameAr;
                              final id = isAll ? null : cats[i - 1].id;
                              final isSelected = _selectedCategoryId == id;
                              return GestureDetector(
                                onTap: () {
                                  setState(
                                      () => _selectedCategoryId = id);
                                  _fetchData();
                                },
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Theme.of(context)
                                            .scaffoldBackgroundColor,
                                    borderRadius:
                                        BorderRadius.circular(17),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.border),

            // ── Grid ─────────────────────────────────────────────────────
            Expanded(
              child: Consumer<ServicesProvider>(
                builder: (context, sp, _) {
                  if (sp.isLoading && sp.services.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (sp.errorMessage != null && sp.services.isEmpty) {
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
                              AppLocalizations.of(context)!.errSearchNetwork,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: _fetchData,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('جرّب تاني'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  List<ServiceItem> services = _searchQuery.isEmpty
                      ? List.from(sp.services)
                      : sp.filterServicesLocally(_searchQuery);

                  if (_selectedSortOption != 'الافتراضي') {
                    services.sort((a, b) => _sortAscending
                        ? a.basePrice.compareTo(b.basePrice)
                        : b.basePrice.compareTo(a.basePrice));
                  }

                  if (services.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.search_off_rounded,
                                size: 48, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.searchEmptyState,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, i) {
                      final s = services[i];
                      return GestureDetector(
                        onTap: () => context.push('/service/${s.id}'),
                        child: ServiceGridCard(service: s),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
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
          color: filled ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: filled ? AppColors.primary : Colors.white,
        ),
      ),
    );
  }
}
