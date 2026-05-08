import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/section_header.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import 'package:manzili_mobile/presentation/providers/seller_provider.dart';
import 'package:manzili_mobile/data/models/seller_models.dart';
import 'package:manzili_mobile/presentation/widgets/common/gradient_app_bar.dart';

/// Screen 3 — Create Service (validation + API integration).
class SellerCreateServiceView extends StatefulWidget {
  const SellerCreateServiceView({super.key});

  @override
  State<SellerCreateServiceView> createState() =>
      _SellerCreateServiceViewState();
}

class _OptionInput {
  final TextEditingController name = TextEditingController();
  final TextEditingController price = TextEditingController();

  void dispose() {
    name.dispose();
    price.dispose();
  }
}

class _OptionGroup {
  final TextEditingController groupName = TextEditingController();
  bool isRequired = true;
  final List<_OptionInput> options = [_OptionInput()];

  void dispose() {
    groupName.dispose();
    for (final o in options) { o.dispose(); }
  }
}

class _SellerCreateServiceViewState extends State<SellerCreateServiceView> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  
  final List<_OptionGroup> _optionGroups = [_OptionGroup()];

  int? _categoryId;
  bool _draft = false;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  bool _isUploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ServicesProvider>().categories.isEmpty) {
        context.read<ServicesProvider>().fetchCategories();
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    for (var g in _optionGroups) { g.dispose(); }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _images.add(file));
    }
  }

  bool _validate() {
    final t = _title.text.trim();
    if (t.length < 3 || t.length > 100) {
      setState(() => _error = AppStrings.errTitleLength);
      return false;
    }
    if (_categoryId == null) {
      setState(() => _error = AppStrings.errCategory);
      return false;
    }
    if (_description.text.trim().length < 20) {
      setState(() => _error = AppStrings.errDescription);
      return false;
    }
    final p = double.tryParse(_price.text.replaceAll(',', '.'));
    if (p == null || p < 0) {
      setState(() => _error = AppStrings.errPrice);
      return false;
    }
    if (_images.isEmpty) {
      setState(() => _error = AppStrings.errImages);
      return false;
    }
    setState(() => _error = null);
    return true;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isUploading = true);

    try {
      final imagePaths = <String>[];
      for (final img in _images) {
        imagePaths.add(img.path);
      }

      final optionGroups = <CreateOptionGroup>[];
      
      for (final g in _optionGroups) {
        final groupName = g.groupName.text.trim();
        if (groupName.isEmpty) continue;
        final validOptions = g.options.where((o) => o.name.text.trim().isNotEmpty).toList();
        if (validOptions.isEmpty) continue;
        optionGroups.add(CreateOptionGroup(
          name: groupName,
          isRequired: g.isRequired,
          options: validOptions.map((o) => CreateOption(
            name: o.name.text.trim(),
            price: double.tryParse(o.price.text.replaceAll(',', '.')) ?? 0.0,
          )).toList(),
        ));
      }

      final req = CreateServiceRequest(
        title: _title.text.trim(),
        description: _description.text.trim(),
        categoryId: _categoryId!,
        basePrice: double.parse(_price.text.replaceAll(',', '.')),
        images: [], // Images are now sent directly via multipart form data files
        optionGroups: optionGroups,
      );

      if (!mounted) return;
      final (success, err) =
          await context.read<SellerProvider>().createService(req, imagePaths);

      if (!mounted) return;
      setState(() => _isUploading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الخدمة بنجاح!')),
        );
        context.pop();
      } else {
        setState(() => _error = err ?? 'فشل الإنشاء');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _error = 'حصل خطأ في رفع الصور أو حفظ الخدمة';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: Column(
          children: [
            const GradientAppBar(
              title: AppStrings.createServiceTitle,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SectionHeader(
                      title: 'التفاصيل الأساسية',
                      subtitle: 'اكتب بصورة واضحة عشان العميل يفهم بسرعة',
                    ),
                    TextField(
                      controller: _title,
                      decoration: const InputDecoration(
                        labelText: AppStrings.fieldServiceTitle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<ServicesProvider>(
                      builder: (context, services, child) {
                        if (services.isLoading && services.categories.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return DropdownButtonFormField<int>(
                          initialValue: _categoryId,
                          hint: const Text(AppStrings.fieldCategory),
                          items: services.categories.map((c) {
                            return DropdownMenuItem<int>(
                              value: c.id,
                              child: Text(c.nameAr),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _categoryId = v),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _description,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: AppStrings.fieldDescription,
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _price,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: AppStrings.fieldBasePrice,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SectionHeader(
                      title: AppStrings.fieldImages,
                      subtitle: 'لازم صورة واحدة على الأقل — هنا معاينة سريعة',
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...List.generate(_images.length, (i) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                  image: DecorationImage(
                                    image: FileImage(File(_images[i].path)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -4,
                                left: -4,
                                child: InkWell(
                                  onTap: () => setState(() => _images.removeAt(i)),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.error,
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        if (_images.length < 5)
                          InkWell(
                            onTap: _pickImage,
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(Icons.add, color: AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Option groups — dynamic, each with name + required toggle + options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'مجموعات الخيارات',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _optionGroups.add(_OptionGroup())),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('مجموعة جديدة'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ..._optionGroups.asMap().entries.map((gEntry) {
                      final gi = gEntry.key;
                      final g = gEntry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: g.groupName,
                                      decoration: const InputDecoration(
                                        labelText: 'اسم المجموعة',
                                        hintText: 'مثال: المقاس، اللون، الإضافات',
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (_optionGroups.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                      onPressed: () => setState(() { g.dispose(); _optionGroups.removeAt(gi); }),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Required / Optional toggle
                              Row(
                                children: [
                                  const Text('النوع:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text('مطلوب'),
                                    selected: g.isRequired,
                                    onSelected: (_) => setState(() => g.isRequired = true),
                                    selectedColor: AppColors.error.withValues(alpha: 0.15),
                                    labelStyle: TextStyle(
                                      color: g.isRequired ? AppColors.error : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text('اختياري'),
                                    selected: !g.isRequired,
                                    onSelected: (_) => setState(() => g.isRequired = false),
                                    selectedColor: AppColors.statusActive.withValues(alpha: 0.15),
                                    labelStyle: TextStyle(
                                      color: !g.isRequired ? AppColors.statusActive : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text('الخيارات:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              const SizedBox(height: 6),
                              ...g.options.asMap().entries.map((oEntry) {
                                final oi = oEntry.key;
                                final o = oEntry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextField(
                                          controller: o.name,
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
                                          controller: o.price,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: const InputDecoration(
                                            hintText: 'السعر',
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      if (g.options.length > 1)
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                          onPressed: () => setState(() { o.dispose(); g.options.removeAt(oi); }),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                              TextButton.icon(
                                onPressed: () => setState(() => g.options.add(_OptionInput())),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('أضف خيار'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(AppStrings.draftToggle),
                      value: _draft,
                      onChanged: (v) => setState(() => _draft = v),
                    ),
                  ],
                ),
              ),
            ),
            _StickyActions(
              isUploading: _isUploading,
              onPrimary: _submit,
              onSecondary: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('تأكيد'),
                    content: const Text(
                      'متأكد إنك عايز تخرج من غير حفظ؟',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('لا'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.pop();
                        },
                        child: const Text('أيوه'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

} 

class _StickyActions extends StatelessWidget {
  const _StickyActions({
    required this.onPrimary,
    required this.onSecondary,
    required this.isUploading,
  });

  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isUploading ? null : onPrimary,
                  child: isUploading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.surface),
                        )
                      : const Text(AppStrings.ctaPublishService),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isUploading ? null : onSecondary,
                  child: const Text(AppStrings.ctaLeaveWithoutSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
