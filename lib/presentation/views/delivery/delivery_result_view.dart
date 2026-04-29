import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';

class DeliveryResultView extends StatelessWidget {
  const DeliveryResultView({super.key, required this.isSuccess});

  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('نتيجة التوصيل'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                size: 96,
                color: isSuccess ? AppColors.statusActive : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess ? 'تم التوصيل بنجاح!' : 'حدث خطأ في التسليم',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
              ),
              const SizedBox(height: 12),
              Text(
                isSuccess
                    ? 'شكراً لمجهودك، تم إضافة الأرباح إلى محفظتك.'
                    : 'الكود غير صحيح، يرجى المحاولة مرة أخرى أو التواصل مع الدعم.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () {
                  if (isSuccess) {
                    context.go('/delivery'); // Back to delivery hub
                  } else {
                    context.pop(); // Go back to verification to retry
                  }
                },
                child: Text(isSuccess ? 'العودة للوحة المندوب' : 'حاول مرة أخرى'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
