import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/providers/seller_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/service_cover_image.dart';
import 'package:manzili_mobile/presentation/widgets/seller/service_status_bottom_sheet.dart';
import 'package:provider/provider.dart';

/// Edit service screen (now loads service from Seller API).
class SellerEditServiceView extends StatefulWidget {
  const SellerEditServiceView({super.key, required this.serviceId});

  final int serviceId;

  @override
  State<SellerEditServiceView> createState() => _SellerEditServiceViewState();
}

class _SellerEditServiceViewState extends State<SellerEditServiceView> {
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _price;
  ManziliServiceStatus _status = ManziliServiceStatus.active;
  List<String> _images = const [];

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _desc = TextEditingController();
    _price = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerProvider>().fetchSellerServiceById(widget.serviceId);
    });
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

  ManziliServiceStatus _mapStatus(String raw) {
    final s = raw.trim().toLowerCase();
    if (s == 'draft') return ManziliServiceStatus.draft;
    if (s == 'blocked' || s == 'inactive' || s == 'paused') {
      return ManziliServiceStatus.paused;
    }
    return ManziliServiceStatus.active;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(

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
                      if (_images.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(AppStrings.errKeepOneImage),
                          ),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('حفظ التعديلات لسه محتاج API للتحديث'),
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
        body: Consumer<SellerProvider>(
          builder: (context, seller, _) {
            if (seller.isLoadingDetails && seller.currentService == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (seller.detailsError != null && seller.currentService == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        seller.detailsError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => seller.fetchSellerServiceById(widget.serviceId),
                        child: const Text('جرّب تاني'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final svc = seller.currentService;
            if (svc != null) {
              // Keep controllers in sync (first load only / when switching id).
              final nextStatus = _mapStatus(svc.status);
              if (_title.text != svc.title) _title.text = svc.title;
              if (_desc.text != svc.description) _desc.text = svc.description;
              final priceStr = svc.basePrice.toStringAsFixed(
                svc.basePrice.truncateToDouble() == svc.basePrice ? 0 : 2,
              );
              if (_price.text != priceStr) _price.text = priceStr;
              if (_images != svc.images) _images = List<String>.from(svc.images);
              if (_status != nextStatus) _status = nextStatus;
            }

            return ListView(
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
                  decoration: const InputDecoration(
                    labelText: AppStrings.fieldServiceTitle,
                  ),
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
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'الصور',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      '(${_images.length})',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_images.isEmpty)
                  const Text(
                    'مفيش صور راجعة من السيرفر للخدمة دي.',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final raw = _images[i];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ServiceCoverImage(
                            imageUrlRaw: raw,
                            width: 84,
                            height: 84,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 18),
                const Text(
                  'مجموعات الخيارات',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (svc == null || svc.optionGroups.isEmpty)
                  const Text(
                    'مفيش خيارات للخدمة دي.',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  ...svc.optionGroups.map((g) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      g.name,
                                      style: const TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  if (g.isRequired)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.statusPending.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'إجباري',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.statusPending,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: g.options.map((o) {
                                  final extra = o.price > 0 ? ' +${o.price}ج' : '';
                                  return Chip(
                                    label: Text('${o.name}$extra'),
                                    backgroundColor: AppColors.surfaceMuted,
                                    side: BorderSide(color: AppColors.border),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 10),
              ],
            );
          },
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
