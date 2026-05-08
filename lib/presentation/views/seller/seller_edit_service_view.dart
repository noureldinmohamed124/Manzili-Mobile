import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/data/models/seller_models.dart';
import 'package:manzili_mobile/presentation/providers/seller_provider.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/service_cover_image.dart';
import 'package:provider/provider.dart';

// ── Editable option group model ───────────────────────────────────────────────

class _EditableOption {
  _EditableOption({String name = '', double price = 0}) {
    nameCtrl = TextEditingController(text: name);
    priceCtrl = TextEditingController(text: price > 0 ? price.toString() : '');
  }
  late final TextEditingController nameCtrl;
  late final TextEditingController priceCtrl;
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
  }
}

class _EditableGroup {
  _EditableGroup({
    String name = '',
    this.isRequired = false,
    List<_EditableOption>? options,
  }) {
    nameCtrl = TextEditingController(text: name);
    this.options = options ?? [_EditableOption()];
  }
  late final TextEditingController nameCtrl;
  bool isRequired;
  late List<_EditableOption> options;
  void dispose() {
    nameCtrl.dispose();
    for (final o in options) {
      o.dispose();
    }
  }
}

// ── Main view ─────────────────────────────────────────────────────────────────

/// Edit service screen — loads service from Seller API, saves via updateService.
/// Status is read-only (backend does not support changing status via PUT).
class SellerEditServiceView extends StatefulWidget {
  const SellerEditServiceView({super.key, required this.serviceId});

  final int serviceId;

  @override
  State<SellerEditServiceView> createState() => _SellerEditServiceViewState();
}

class _SellerEditServiceViewState extends State<SellerEditServiceView> {
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _price;

  int? _categoryId;
  List<String> _existingImages = const [];
  final List<XFile> _newImages = [];
  List<_EditableGroup> _groups = [];
  bool _isSaving = false;
  String? _saveError;

  /// Tracks which service ID was last synced into the controllers.
  /// When this differs from widget.serviceId, all state is reset and re-synced.
  int? _loadedServiceId;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _desc = TextEditingController();
    _price = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerProvider>().fetchSellerServiceById(widget.serviceId);
      if (context.read<ServicesProvider>().categories.isEmpty) {
        context.read<ServicesProvider>().fetchCategories();
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _price.dispose();
    for (final g in _groups) {
      g.dispose();
    }
    super.dispose();
  }

  /// Resets all editable state and syncs from [svc].
  /// Called exactly once per service ID change.
  void _syncFromService(SellerServiceDetails svc) {
    _title.text = svc.title;
    _desc.text = svc.description;
    _price.text = svc.basePrice.truncateToDouble() == svc.basePrice
        ? svc.basePrice.toStringAsFixed(0)
        : svc.basePrice.toStringAsFixed(2);
    _existingImages = List.from(svc.images);
    _categoryId = null; // reset — will be resolved below

    // Dispose old groups before replacing
    for (final g in _groups) {
      g.dispose();
    }
    _groups = svc.optionGroups
        .map((g) => _EditableGroup(
              name: g.name,
              isRequired: g.isRequired,
              options: g.options
                  .map((o) => _EditableOption(name: o.name, price: o.price))
                  .toList(),
            ))
        .toList();
    if (_groups.isEmpty) _groups.add(_EditableGroup());

    // Pre-select category by matching name from categories list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cats = context.read<ServicesProvider>().categories;
      final match = cats
          .where((c) =>
              c.nameAr.trim().toLowerCase() ==
              svc.category.trim().toLowerCase())
          .firstOrNull;
      if (match != null) {
        setState(() => _categoryId = match.id);
      }
    });
    // Note: _loadedServiceId is set by the caller before invoking this method
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _newImages.add(file));
  }

  List<CreateOptionGroup> _buildOptionGroups() {
    return _groups
        .where((g) => g.nameCtrl.text.trim().isNotEmpty)
        .map((g) => CreateOptionGroup(
              name: g.nameCtrl.text.trim(),
              isRequired: g.isRequired,
              options: g.options
                  .where((o) => o.nameCtrl.text.trim().isNotEmpty)
                  .map((o) => CreateOption(
                        name: o.nameCtrl.text.trim(),
                        price: double.tryParse(
                                o.priceCtrl.text.replaceAll(',', '.')) ??
                            0,
                      ))
                  .toList(),
            ))
        .toList();
  }

  Future<void> _save(SellerServiceDetails svc) async {
    if (_existingImages.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errKeepOneImage)),
      );
      return;
    }

    int resolvedCategoryId = _categoryId ?? 0;
    if (resolvedCategoryId == 0) {
      final cats = context.read<ServicesProvider>().categories;
      final match = cats
          .where((c) =>
              c.nameAr.trim().toLowerCase() ==
              svc.category.trim().toLowerCase())
          .firstOrNull;
      if (match != null) resolvedCategoryId = match.id;
    }
    if (resolvedCategoryId == 0) {
      setState(() => _saveError = 'اختار الفئة الأول');
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    final request = CreateServiceRequest(
      title: _title.text.trim(),
      description: _desc.text.trim(),
      categoryId: resolvedCategoryId,
      basePrice:
          double.tryParse(_price.text.replaceAll(',', '.')) ?? svc.basePrice,
      images: [],
      optionGroups: _buildOptionGroups(),
    );

    final imagePaths = _newImages.map((f) => f.path).toList();

    if (!mounted) return;
    final (ok, err) = await context
        .read<SellerProvider>()
        .updateService(widget.serviceId, request, imagePaths);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _saveError = err;
    });

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التعديلات بنجاح')),
      );
      context.pop();
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هتحذف الخدمة دي؟ مش هترجع.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('لا')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('أيوه، احذف'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final (ok, err) =
        await context.read<SellerProvider>().deleteService(widget.serviceId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم حذف الخدمة بنجاح')));
      context.pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err ?? 'فشل الحذف')));
    }
  }

  String _statusLabel(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'active':
        return 'نشطة';
      case 'draft':
        return 'مسودة';
      case 'blocked':
      case 'inactive':
      case 'paused':
        return 'موقوفة';
      default:
        return raw.isEmpty ? '—' : raw;
    }
  }

  Color _statusColor(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'active':
        return AppColors.statusActive;
      case 'draft':
        return AppColors.statusPending;
      default:
        return AppColors.statusInactive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.editServiceTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _confirmDelete,
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => context.pop(),
                    child: const Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Consumer<SellerProvider>(
                    builder: (context, seller, _) {
                      final svc = seller.currentService;
                      return FilledButton(
                        onPressed: (_isSaving || svc == null)
                            ? null
                            : () => _save(svc),
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text(AppStrings.ctaSaveEdits),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Consumer<SellerProvider>(
          builder: (context, seller, _) {
            if (seller.isLoadingDetails && seller.currentService == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (seller.detailsError != null &&
                seller.currentService == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(seller.detailsError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => seller
                            .fetchSellerServiceById(widget.serviceId),
                        child: const Text('جرّب تاني'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final svc = seller.currentService;

            // Sync controllers exactly once per service ID.
            // Set _loadedServiceId immediately to prevent duplicate scheduling
            // from multiple rebuilds before the postFrameCallback fires.
            if (svc != null && _loadedServiceId != widget.serviceId) {
              _loadedServiceId = widget.serviceId; // guard against re-entry
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _syncFromService(svc));
              });
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Error banner
                if (_saveError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(_saveError!,
                            style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),

                // Status — read-only (backend doesn't support changing via PUT)
                if (svc != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _statusColor(svc.status).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _statusColor(svc.status).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: _statusColor(svc.status)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الحالة: ${_statusLabel(svc.status)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _statusColor(svc.status),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'تغيير الحالة مش متاح حالياً من خلال التعديل',
                                style: TextStyle(fontSize: 11, color: AppColors.textHint),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Title
                TextField(
                    controller: _title,
                    decoration: const InputDecoration(
                        labelText: AppStrings.fieldServiceTitle)),
                const SizedBox(height: 12),

                // Description
                TextField(
                    controller: _desc,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                        labelText: AppStrings.fieldDescription)),
                const SizedBox(height: 12),

                // Price
                TextField(
                    controller: _price,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: AppStrings.fieldBasePrice)),
                const SizedBox(height: 12),

                // Category dropdown
                Consumer<ServicesProvider>(
                  builder: (context, services, _) {
                    if (services.isLoading && services.categories.isEmpty) {
                      return const SizedBox(
                          height: 56,
                          child: Center(child: CircularProgressIndicator()));
                    }
                    if (services.categories.isEmpty) {
                      return OutlinedButton.icon(
                        onPressed: () => services.fetchCategories(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('تحميل الفئات'),
                      );
                    }
                    return DropdownButtonFormField<int>(
                      value: _categoryId,
                      hint: const Text('اختار الفئة'),
                      decoration: const InputDecoration(
                          labelText: 'الفئة',
                          border: OutlineInputBorder()),
                      items: services.categories
                          .map((c) => DropdownMenuItem<int>(
                              value: c.id, child: Text(c.nameAr)))
                          .toList(),
                      onChanged: (v) => setState(() => _categoryId = v),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Images
                Row(children: [
                  const Expanded(
                      child: Text('الصور',
                          style: TextStyle(fontWeight: FontWeight.w800))),
                  Text('(${_existingImages.length + _newImages.length})',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._existingImages.asMap().entries.map((entry) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: ServiceCoverImage(
                                    imageUrlRaw: entry.value,
                                    width: 84,
                                    height: 84)),
                            Positioned(
                              top: -4,
                              left: -4,
                              child: InkWell(
                                onTap: () => setState(
                                    () => _existingImages.removeAt(entry.key)),
                                child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.error,
                                    child: Icon(Icons.close,
                                        size: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface)),
                              ),
                            ),
                          ],
                        )),
                    ..._newImages.asMap().entries.map((entry) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                                image: DecorationImage(
                                    image: FileImage(File(entry.value.path)),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              top: -4,
                              left: -4,
                              child: InkWell(
                                onTap: () => setState(
                                    () => _newImages.removeAt(entry.key)),
                                child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.error,
                                    child: Icon(Icons.close,
                                        size: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface)),
                              ),
                            ),
                          ],
                        )),
                    if (_existingImages.length + _newImages.length < 5)
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.primary, width: 1.5),
                          ),
                          child: const Icon(Icons.add,
                              color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Option groups — fully editable
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('مجموعات الخيارات',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _groups.add(_EditableGroup())),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('مجموعة جديدة'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._groups.asMap().entries.map((gEntry) {
                  final gi = gEntry.key;
                  final g = gEntry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: TextField(
                                controller: g.nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'اسم المجموعة',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(children: [
                              const Text('إلزامي',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                              Switch.adaptive(
                                value: g.isRequired,
                                onChanged: (v) =>
                                    setState(() => g.isRequired = v),
                              ),
                            ]),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.error, size: 20),
                              onPressed: _groups.length > 1
                                  ? () => setState(() {
                                        g.dispose();
                                        _groups.removeAt(gi);
                                      })
                                  : null,
                            ),
                          ]),
                          const SizedBox(height: 10),
                          const Text('الخيارات:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          ...g.options.asMap().entries.map((oEntry) {
                            final oi = oEntry.key;
                            final o = oEntry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: o.nameCtrl,
                                    decoration: const InputDecoration(
                                      hintText: 'اسم الخيار',
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: o.priceCtrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                      hintText: 'السعر',
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                      size: 20),
                                  onPressed: g.options.length > 1
                                      ? () => setState(() {
                                            o.dispose();
                                            g.options.removeAt(oi);
                                          })
                                      : null,
                                ),
                              ]),
                            );
                          }),
                          TextButton.icon(
                            onPressed: () =>
                                setState(() => g.options.add(_EditableOption())),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('أضف خيار'),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
    );
  }
}
