import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

enum VipState { active, expired, none }

class SellerVipView extends StatefulWidget {
  const SellerVipView({super.key});

  @override
  State<SellerVipView> createState() => _SellerVipViewState();
}

class _SellerVipViewState extends State<SellerVipView> {
  VipState _state = VipState.none;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(AppStrings.vipTitle),
        actions: [
          PopupMenuButton<VipState>(
            onSelected: (v) => setState(() => _state = v),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: VipState.active,
                child: Text(AppStrings.vipActive),
              ),
              const PopupMenuItem(
                value: VipState.expired,
                child: Text(AppStrings.vipExpired),
              ),
              const PopupMenuItem(
                value: VipState.none,
                child: Text(AppStrings.vipNone),
              ),
            ],
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: AppColors.secondary, size: 32),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _stateLabel(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _stateHint(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text(AppStrings.vipCtaMore),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _state == VipState.active ? null : () {},
                        child: const Text(AppStrings.vipCtaSubscribe),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'الأدوات',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _toolTile('بوست مميز أسبوعي', locked: _state != VipState.active),
          _toolTile('قوالب احترافية للعروض', locked: _state != VipState.active),
          _toolTile('تقارير متقدمة', locked: _state != VipState.active),
        ],
      ),
    );
  }

  String _stateLabel() {
    switch (_state) {
      case VipState.active:
        return AppStrings.vipActive;
      case VipState.expired:
        return AppStrings.vipExpired;
      case VipState.none:
        return AppStrings.vipNone;
    }
  }

  String _stateHint() {
    switch (_state) {
      case VipState.active:
        return 'استمتع بكل مزايا VIP — وظبط شغلك أسرع.';
      case VipState.expired:
        return 'جدّد اشتراكك عشان ترجع الأدوات القوية.';
      case VipState.none:
        return 'اشترك في VIP وابدأ تستخدم أدوات تساعدك تكبر.';
    }
  }

  Widget _toolTile(String title, {required bool locked}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        child: Row(
          children: [
            Icon(
              locked ? Icons.lock_outline : Icons.check_circle_outline,
              color: locked ? AppColors.statusInactive : AppColors.statusActive,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: locked ? AppColors.textSecondary : AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              locked ? AppStrings.vipLocked : AppStrings.vipUnlocked,
              style: TextStyle(
                fontSize: 12,
                color: locked ? AppColors.textHint : AppColors.statusActive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
