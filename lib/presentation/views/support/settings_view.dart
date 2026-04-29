import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;
  bool _offersEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(

        appBar: AppBar(
          title: const Text(AppStrings.navSettings),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SoftCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('إشعارات الطلبات'),
                      value: _notificationsEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('عروض وخصومات'),
                      value: _offersEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _offersEnabled = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              onTap: () {
                context.read<AuthProvider>().logout();
                context.go('/signin');
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.error),
                    SizedBox(width: 12),
                    Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
