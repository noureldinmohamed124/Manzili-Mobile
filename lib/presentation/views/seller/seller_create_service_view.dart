import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/section_header.dart';

/// Screen 3 — Create Service (validation + UX per spec; POST when API is ready).
class SellerCreateServiceView extends StatefulWidget {
  const SellerCreateServiceView({super.key});

  @override
  State<SellerCreateServiceView> createState() =>
      _SellerCreateServiceViewState();
}

class _SellerCreateServiceViewState extends State<SellerCreateServiceView> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _variants = TextEditingController();
  final _extras = TextEditingController();

  String? _category;
  bool _draft = false;
  int _imageCount = 1;

  final _categories = const [
    'أكل بيتي',
    'حلويات',
    'شغل يدوي',
    'خدمات منزلية',
    'أخرى',
  ];

  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    _variants.dispose();
    _extras.dispose();
    super.dispose();
  }

  bool _validate() {
    final t = _title.text.trim();
    if (t.length < 3 || t.length > 100) {
      setState(() => _error = AppStrings.errTitleLength);
      return false;
    }
    if (_category == null) {
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
    if (_imageCount < 1) {
      setState(() => _error = AppStrings.errImages);
      return false;
    }
    setState(() => _error = null);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
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
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      hint: const Text(AppStrings.fieldCategory),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _category = v),
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
                        ...List.generate(_imageCount, (i) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(
                                  Icons.image_outlined,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (_imageCount > 1)
                                Positioned(
                                  top: -4,
                                  left: -4,
                                  child: InkWell(
                                    onTap: () => setState(() {
                                      if (_imageCount > 1) _imageCount--;
                                    }),
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
                        InkWell(
                          onTap: () =>
                              setState(() => _imageCount++),
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
                    const SectionHeader(title: AppStrings.fieldVariants),
                    TextField(
                      controller: _variants,
                      decoration: const InputDecoration(
                        hintText: 'مثال: حجم صغير / كبير — سعر كل خيار',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SectionHeader(title: AppStrings.fieldExtras),
                    TextField(
                      controller: _extras,
                      decoration: const InputDecoration(
                        hintText: 'مثال: تغليف هدية، توصيل سريع…',
                      ),
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
              onPrimary: () {
                if (!_validate()) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _draft
                          ? 'تم حفظ المسودة (محليًا) — هيتربط بالسيرفر لاحقًا'
                          : 'تمام! جاهزين نربطوا بالـ API لما يكون جاهز',
                    ),
                  ),
                );
                context.pop();
              },
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
  });

  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: AppColors.surface,
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
                  onPressed: onPrimary,
                  child: const Text(AppStrings.ctaPublishService),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onSecondary,
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
