import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';

class SupportConfirmationView extends StatelessWidget {
  const SupportConfirmationView({
    super.key,
    required this.ticketNumber,
  });

  final String ticketNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_read_rounded,
                size: 72,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.supportSuccessTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${AppStrings.supportTicketLabel}: $ticketNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.supportNextSteps,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('تمام'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
