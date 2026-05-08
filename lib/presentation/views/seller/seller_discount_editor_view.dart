import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/widgets/common/gradient_app_bar.dart';

class SellerDiscountEditorView extends StatefulWidget {
  const SellerDiscountEditorView({super.key});

  @override
  State<SellerDiscountEditorView> createState() =>
      _SellerDiscountEditorViewState();
}

class _SellerDiscountEditorViewState extends State<SellerDiscountEditorView> {
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  bool _isPercentage = true;

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const GradientAppBar(title: 'إضافة خصم جديد'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SoftCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('كود الخصم',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            hintText: 'مثال: SUMMER20',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('نوع الخصم',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isPercentage = true),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isPercentage
                                        ? AppColors.primary
                                            .withValues(alpha: 0.1)
                                        : AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: _isPercentage
                                            ? AppColors.primary
                                            : AppColors.border),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'نسبة مئوية (%)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: _isPercentage
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isPercentage = false),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isPercentage
                                        ? AppColors.primary
                                            .withValues(alpha: 0.1)
                                        : AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: !_isPercentage
                                            ? AppColors.primary
                                            : AppColors.border),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'مبلغ ثابت (ج)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: !_isPercentage
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('قيمة الخصم',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _valueController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: _isPercentage ? 'مثال: 20' : 'مثال: 50',
                            suffixText: _isPercentage ? '%' : 'جنيه',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    // TODO: Call API to create discount
                    context.pop();
                  },
                  child: const Text('حفظ الخصم'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
