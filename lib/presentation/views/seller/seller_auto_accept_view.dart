import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

/// Screen 6 — Auto accept (disabled when paused).
class SellerAutoAcceptView extends StatefulWidget {
  const SellerAutoAcceptView({super.key});

  @override
  State<SellerAutoAcceptView> createState() => _SellerAutoAcceptViewState();
}

class _SellerAutoAcceptViewState extends State<SellerAutoAcceptView> {
  bool _serviceActive = true;
  bool _paused = false;
  bool _auto = false;

  bool get _enabled => _serviceActive && !_paused;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.autoAcceptTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('الخدمة نشطة (تجربة)'),
                  value: _serviceActive,
                  onChanged: (v) => setState(() {
                    _serviceActive = v;
                    if (!_enabled) _auto = false;
                  }),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('موقوفة مؤقتًا'),
                  value: _paused,
                  onChanged: (v) => setState(() {
                    _paused = v;
                    if (!_enabled) _auto = false;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(AppStrings.autoAcceptSubtitle),
                  subtitle: const Text(AppStrings.autoAcceptHint),
                  value: _auto && _enabled,
                  onChanged: _enabled
                      ? (v) => setState(() {
                            _auto = v;
                          })
                      : null,
                ),
              ],
            ),
          ),
          if (!_enabled)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _paused
                    ? 'مش هتقدر تفعّل القبول التلقائي والخدمة موقوفة.'
                    : 'لازم تكون الخدمة شغّالة عشان تقدر تفعّل القبول التلقائي.',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
