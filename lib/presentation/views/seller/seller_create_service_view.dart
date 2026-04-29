import 'dart:convert';
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

class _SellerCreateServiceViewState extends State<SellerCreateServiceView> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  
  final List<_OptionInput> _variantInputs = [_OptionInput()];
  final List<_OptionInput> _extraInputs = [_OptionInput()];

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
    for (var v in _variantInputs) { v.dispose(); }
    for (var e in _extraInputs) { e.dispose(); }
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
      
      final validVariants = _variantInputs.where((v) => v.name.text.trim().isNotEmpty).toList();
      if (validVariants.isNotEmpty) {
        optionGroups.add(CreateOptionGroup(
          name: 'خيارات / مقاسات',
          isRequired: true,
          options: validVariants.map((v) => CreateOption(
            name: v.name.text.trim(),
            price: double.tryParse(v.price.text.replaceAll(',', '.')) ?? 0.0,
          )).toList(),
        ));
      }
      
      final validExtras = _extraInputs.where((e) => e.name.text.trim().isNotEmpty).toList();
      if (validExtras.isNotEmpty) {
        optionGroups.add(CreateOptionGroup(
          name: 'مميزات إضافية',
          isRequired: false,
          options: validExtras.map((e) => CreateOption(
            name: e.name.text.trim(),
            price: double.tryParse(e.price.text.replaceAll(',', '.')) ?? 0.0,
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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.createServiceTitle),
        ),
        body: Column(
          children: [
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
                          value: _categoryId,
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
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.error,
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
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
                    _buildDynamicList(
                      AppStrings.fieldVariants,
                      _variantInputs,
                      () => setState(() => _variantInputs.add(_OptionInput())),
                    ),
                    const SizedBox(height: 12),
                    _buildDynamicList(
                      AppStrings.fieldExtras,
                      _extraInputs,
                      () => setState(() => _extraInputs.add(_OptionInput())),
                    ),
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

  Widget _buildDynamicList(
    String title,
    List<_OptionInput> list,
    VoidCallback onAdd,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        ...list.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: item.name,
                    decoration: const InputDecoration(
                      hintText: 'الاسم',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: item.price,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: 'السعر',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                if (list.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        item.dispose();
                        list.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('إضافة خيار آخر'),
        ),
      ],
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
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
