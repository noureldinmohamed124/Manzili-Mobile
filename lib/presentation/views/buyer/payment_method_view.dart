import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class PaymentMethodView extends StatefulWidget {
  const PaymentMethodView({super.key});

  @override
  State<PaymentMethodView> createState() => _PaymentMethodViewState();
}

class _PaymentMethodViewState extends State<PaymentMethodView> {
  String _selectedMethod = 'cash';
  bool _isUploading = false;

  void _submitPayment() async {
    if (_selectedMethod == 'bank_transfer') {
      setState(() => _isUploading = true);
      // Fake upload delay
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isUploading = false);
    }

    if (!mounted) return;
    context.go('/order-placed');
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
                    const Text('بعد التحويل، ارفع صورة إيصال الدفع هنا.'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file),
                      label: const Text('إرفاق الإيصال (صورة أو PDF)'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _isUploading ? null : _submitPayment,
            child: _isUploading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('تأكيد وإتمام الدفع'),
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
