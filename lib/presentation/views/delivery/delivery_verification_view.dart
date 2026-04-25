import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class DeliveryVerificationView extends StatefulWidget {
  const DeliveryVerificationView({super.key, required this.deliveryId});
  
  final String deliveryId;

  @override
  State<DeliveryVerificationView> createState() => _DeliveryVerificationViewState();
}

class _DeliveryVerificationViewState extends State<DeliveryVerificationView> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  void _verifyDelivery() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);
    
    // TODO: Connect to backend API to verify code
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Mock logic: 1234 is success, anything else is fail
    if (code == '4829' || code == '1234') {
      context.pushReplacement('/delivery/result/success');
    } else {
      context.pushReplacement('/delivery/result/failed');
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تأكيد التسليم (#${widget.deliveryId})'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.verified_user_outlined, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'كود التأكيد',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Text(
            'برجاء إدخال الكود المكون من ٤ أرقام الذي يمتلكه العميل لتأكيد إتمام التوصيل بنجاح.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 32),
          SoftCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 16),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '----',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _isLoading ? null : _verifyDelivery,
            child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('تأكيد التسليم'),
          ),
        ],
      ),
    );
  }
}
