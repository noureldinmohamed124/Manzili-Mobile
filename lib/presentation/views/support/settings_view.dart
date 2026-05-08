import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/providers/theme_provider.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // ── Gradient header ────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [const Color(0xFF2A1A14), const Color(0xFF1A1A1A)]
                      : [AppColors.primary, AppColors.secondary],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          AppStrings.navSettings,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Settings body ──────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  // ── Appearance section ───────────────────────────────
                  _SectionLabel('المظهر'),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    child: Consumer<ThemeProvider>(
                      builder: (context, tp, _) => _SettingsTile(
                        icon: tp.isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        iconColor: AppColors.primary,
                        title: 'الوضع الليلي',
                        trailing: Switch(
                          value: tp.isDarkMode,
                          activeColor: AppColors.primary,
                          onChanged: (_) => tp.toggleTheme(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Notifications section ────────────────────────────
                  _SectionLabel('الإشعارات'),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.notifications_rounded,
                          iconColor: const Color(0xFF42A5F5),
                          title: 'إشعارات الطلبات',
                          trailing: Switch(
                            value: _notificationsEnabled,
                            activeColor: AppColors.primary,
                            onChanged: (val) =>
                                setState(() => _notificationsEnabled = val),
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: AppColors.border.withValues(alpha: 0.6),
                        ),
                        _SettingsTile(
                          icon: Icons.local_offer_rounded,
                          iconColor: AppColors.secondary,
                          title: 'عروض وخصومات',
                          trailing: Switch(
                            value: _offersEnabled,
                            activeColor: AppColors.primary,
                            onChanged: (val) =>
                                setState(() => _offersEnabled = val),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── About section ────────────────────────────────────
                  _SectionLabel('عن التطبيق'),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    child: _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: const Color(0xFF26A69A),
                      title: 'إصدار التطبيق',
                      trailing: const Text(
                        '1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Account section ──────────────────────────────────
                  _SectionLabel('الحساب'),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    child: _SettingsTile(
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.error,
                      title: 'تسجيل الخروج',
                      titleColor: AppColors.error,
                      onTap: () {
                        context.read<AuthProvider>().logout();
                        context.go('/signin');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ── Settings Card ─────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Settings Tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
    this.titleColor,
    this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: titleColor ??
                        (Theme.of(context).textTheme.bodyLarge?.color ??
                            AppColors.textPrimary),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
