import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';

class OrderPlacedView extends StatelessWidget {
  const OrderPlacedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 88,
                color: AppColors.statusActive,
              ),
              const SizedBox(height: 24),
              const Text(
                'تمام! طلبك اتسجل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'هنبعتلك تحديث على الإشعارات لما الطلب يتحرك.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => context.go('/my-orders'),
                child: const Text('شوف طلباتي'),
              ),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('ارجع للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
