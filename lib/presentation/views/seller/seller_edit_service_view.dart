import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/seller/service_status_bottom_sheet.dart';

/// Screen 4 — Edit service (prefilled mock + status sheet).
class SellerEditServiceView extends StatefulWidget {
  const SellerEditServiceView({super.key});

  @override
  State<SellerEditServiceView> createState() => _SellerEditServiceViewState();
}

class _SellerEditServiceViewState extends State<SellerEditServiceView> {
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _price;
  ManziliServiceStatus _status = ManziliServiceStatus.active;
  int _images = 2;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: 'كيكة فراولة من البيت');
    _desc = TextEditingController(
      text: 'كيكة طازة طعمها حلو ومن غير مواد غريبة — مناسبة لأي مناسبة.',
    );
    _price = TextEditingController(text: '120');
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _openStatus() async {
    final next = await showServiceStatusSheet(
      context,
      current: _status,
    );
    if (next != null) setState(() => _status = next);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.editServiceTitle),
          actions: [
            TextButton(
              onPressed: _openStatus,
              child: const Text('الحالة'),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_images < 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(AppStrings.errKeepOneImage),
                          ),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم حفظ التعديلات (محليًا)'),
                        ),
                      );
                      context.pop();
                    },
                    child: const Text(AppStrings.ctaSaveEdits),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('الحالة الحالية'),
              trailing: Chip(
                label: Text(_statusLabel(_status)),
                backgroundColor: _statusColor(_status).withValues(alpha: 0.15),
              ),
              onTap: _openStatus,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: AppStrings.fieldServiceTitle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldDescription,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: AppStrings.fieldBasePrice),
            ),
            const SizedBox(height: 16),
            const Text(
              'الصور',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(_images, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.image),
                        ),
                        if (_images > 1)
                          Positioned(
                            top: -6,
                            left: -6,
                            child: InkWell(
                              onTap: () => setState(() => _images--),
                              child: const CircleAvatar(
                                radius: 11,
                                backgroundColor: AppColors.error,
                                child: Icon(Icons.close, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                IconButton(
                  onPressed: () => setState(() => _images++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(ManziliServiceStatus s) {
    switch (s) {
      case ManziliServiceStatus.active:
        return AppStrings.statusActive;
      case ManziliServiceStatus.paused:
        return AppStrings.statusPaused;
      case ManziliServiceStatus.draft:
        return AppStrings.statusDraft;
    }
  }

  Color _statusColor(ManziliServiceStatus s) {
    switch (s) {
      case ManziliServiceStatus.active:
        return AppColors.statusActive;
      case ManziliServiceStatus.paused:
        return AppColors.statusInactive;
      case ManziliServiceStatus.draft:
        return AppColors.statusPending;
    }
  }
}
