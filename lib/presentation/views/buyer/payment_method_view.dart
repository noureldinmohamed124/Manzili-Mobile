import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/orders_provider.dart';
import 'package:provider/provider.dart';

class PaymentMethodView extends StatefulWidget {
  const PaymentMethodView({super.key});

  @override
  State<PaymentMethodView> createState() => _PaymentMethodViewState();
}

class _PaymentMethodViewState extends State<PaymentMethodView> {
  String _selectedMethod = 'cash';
  final _receipt = TextEditingController();
  final _notes = TextEditingController();

  void _submitPayment() async {
    if (_selectedMethod == 'bank_transfer') {
      final ok = await context.read<OrdersProvider>().submitPaymentProof(
            paymentScreenshot: _receipt.text,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          );
      if (!mounted) return;
      if (!ok) return;
    }

    if (!mounted) return;
    context.go('/order-placed');
  }

  @override
  void dispose() {
    _receipt.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طريقة الدفع'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'اختر طريقة الدفع المناسبة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              children: [
                _buildMethodOption('كاش عند الاستلام', 'cash', Icons.money),
                const Divider(height: 1),
                _buildMethodOption('محفظتي', 'wallet', Icons.account_balance_wallet),
                const Divider(height: 1),
                _buildMethodOption('تحويل بنكي / إنستا باي', 'bank_transfer', Icons.account_balance),
              ],
            ),
          ),
          if (_selectedMethod == 'bank_transfer') ...[
            const SizedBox(height: 24),
            const Text(
              'بيانات التحويل',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SoftCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('برجاء تحويل المبلغ على حساب إنستا باي التالي:'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'manzili@instapay',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                        ),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ')));
                          },
                          icon: const Icon(Icons.copy, size: 20),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text('بعد التحويل، ابعت صورة الإيصال/سكرين التحويل.'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _receipt,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'PaymentScreenshot',
                        hintText: 'حط هنا Base64 أو لينك للصورة (حسب السيرفر)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _notes,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        hintText: 'أي تفاصيل زيادة عن التحويل…',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Consumer<OrdersProvider>(
                      builder: (context, orders, _) {
                        final err = orders.errorMessage;
                        if (err == null || err.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            err,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Consumer<OrdersProvider>(
            builder: (context, orders, _) {
              final busy = orders.isSubmittingPaymentProof;
              return FilledButton(
                onPressed: busy ? null : _submitPayment,
                child: busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('تأكيد وإتمام الدفع'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMethodOption(String title, String value, IconData icon) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      value: value,
      groupValue: _selectedMethod,
      onChanged: (val) {
        if (val != null) setState(() => _selectedMethod = val);
      },
      activeColor: AppColors.primary,
    );
  }
}
