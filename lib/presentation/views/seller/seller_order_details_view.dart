import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/service_cover_image.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/seller_provider.dart';
import 'package:provider/provider.dart';

class SellerOrderDetailsView extends StatefulWidget {
  const SellerOrderDetailsView({super.key, required this.orderId});

  final String orderId;

  @override
  State<SellerOrderDetailsView> createState() => _SellerOrderDetailsViewState();
}

class _SellerOrderDetailsViewState extends State<SellerOrderDetailsView> {
  String? _selectedNextStatus;

  /// Tracks which order ID was last loaded to detect navigation to a different order.
  int? _loadedOrderId;

  /// Returns the valid next statuses the seller can set from [currentStatus].
  /// Based on live API testing — the backend enforces strict lifecycle transitions.
  static List<Map<String, String>> _validTransitions(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'paid':
        return [{'value': 'InProgress', 'label': 'ابدأ التنفيذ'}];
      case 'inprogress':
        return [{'value': 'ReadyForShipping', 'label': 'جاهز للشحن'}];
      case 'readyforshipping':
        return [{'value': 'OutForDelivery', 'label': 'في الطريق للعميل'}];
      case 'outfordelivery':
        return [{'value': 'Shipped', 'label': 'تم التسليم'}];
      // Accepted: buyer must pay first — no seller action available
      // Shipped: admin must confirm payout — no seller action available
      default:
        return [];
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear stale order data before fetching the new one
      context.read<SellerProvider>().clearCurrentOrder();
      context.read<SellerProvider>().fetchSellerOrderById(_orderId);
    });
  }

  int get _orderId => int.tryParse(widget.orderId) ?? 0;

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'request':
        return AppColors.statusPending;
      case 'accepted':
        return AppColors.statusActive;
      case 'rejected':
        return AppColors.error;
      case 'paid':
        return Colors.blue;
      case 'inprogress':
        return Colors.orange;
      case 'readyforshipping':
      case 'outfordelivery':
      case 'shipped':
        return Colors.indigo;
      case 'confirmed':
        return AppColors.statusActive;
      default:
        return AppColors.statusInactive;
    }
  }

  String _statusAr(String s) {
    switch (s.toLowerCase()) {
      case 'request':
        return 'طلب جديد';
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'paid':
        return 'مدفوع';
      case 'inprogress':
        return 'قيد التنفيذ';
      case 'readyforshipping':
        return 'جاهز للشحن';
      case 'outfordelivery':
        return 'في الطريق';
      case 'shipped':
        return 'تم الشحن';
      case 'confirmed':
        return 'مكتمل';
      default:
        return s;
    }
  }

  Future<void> _approve(SellerProvider provider) async {
    final (ok, err) = await provider.approveOrder(_orderId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم قبول الطلب بنجاح')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'فشل قبول الطلب')),
      );
    }
  }

  Future<void> _reject(SellerProvider provider) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('سبب الرفض'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'اكتب السبب هنا...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('رفض'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final (ok, err) = await provider.rejectOrder(_orderId, controller.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفض الطلب')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'فشل رفض الطلب')),
      );
    }
  }

  Future<void> _reprice(SellerProvider provider) async {
    final priceCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة تسعير'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'السعر الجديد'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(hintText: 'السبب'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final price = double.tryParse(priceCtrl.text) ?? 0;
    final (ok, err) =
        await provider.repriceOrder(_orderId, price, reasonCtrl.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(ok ? 'تم إرسال التسعير الجديد' : (err ?? 'فشل التسعير'))),
    );
  }

  /// Returns a human-readable explanation when no seller transition is available.
  static String _getWaitingMessage(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'الطلب اتقبل وبينتظر دفع العميل. لما العميل يدفع وتتأكد المدفوعة من الإدارة، هتقدر تبدأ التنفيذ.';
      case 'pendingpaymentverification':
        return 'في انتظار تأكيد الدفع من الإدارة.';
      case 'shipped':
        return 'الطلب اتشحن وبينتظر تأكيد الإدارة لصرف المبلغ.';
      case 'confirmed':
        return 'الطلب مكتمل.';
      case 'rejected':
        return 'الطلب اترفض.';
      default:
        return 'مفيش إجراء متاح دلوقتي.';
    }
  }

  Future<void> _updateStatus(SellerProvider provider) async {    if (_selectedNextStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختار الحالة الجديدة الأول')),
      );
      return;
    }
    final (ok, err) =
        await provider.updateOrderStatus(_orderId, _selectedNextStatus!);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث حالة الطلب')),
      );
      provider.fetchSellerOrderById(_orderId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'فشل تحديث الحالة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل طلب #${widget.orderId}'),
      ),
      body: Consumer<SellerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingOrderDetails && provider.currentOrder == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.orderDetailsError != null &&
              provider.currentOrder == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.orderDetailsError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          provider.fetchSellerOrderById(_orderId),
                      child: const Text('جرّب تاني'),
                    ),
                  ],
                ),
              ),
            );
          }

          final order = provider.currentOrder;
          if (order == null) {
            return const Center(
              child: Text(
                'مفيش بيانات للطلب ده.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          // Bug 4 fix: reset _selectedNextStatus when navigating to a different order
          if (_loadedOrderId != _orderId) {
            _loadedOrderId = _orderId;
            // Reset status selection for the new order
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _selectedNextStatus = null);
            });
          }

          final isRequest = order.status.toLowerCase() == 'request';
          final isAcceptedOrLater = !isRequest &&
              order.status.toLowerCase() != 'rejected';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Service image + title
              SoftCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: ServiceCoverImage(
                        imageUrlRaw: order.serviceImage,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.serviceTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(order.status)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _statusAr(order.status),
                                  style: TextStyle(
                                    color: _statusColor(order.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (order.createdAt != null) ...[
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(order.createdAt!),
                                  style: const TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Buyer info
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'بيانات العميل',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'الاسم', value: order.buyerName),
                    const SizedBox(height: 6),
                    _InfoRow(label: 'التليفون', value: order.buyerPhone),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pricing
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'التسعير',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                        label: 'السعر الأساسي',
                        value: '${order.rawPrice.toStringAsFixed(2)} جنيه'),
                    const SizedBox(height: 6),
                    _InfoRow(
                        label: 'الإجمالي',
                        value: '${order.totalPrice.toStringAsFixed(2)} جنيه',
                        valueStyle: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    if (order.proposedPrice != null) ...[
                      const SizedBox(height: 6),
                      _InfoRow(
                          label: 'السعر المقترح',
                          value:
                              '${order.proposedPrice!.toStringAsFixed(2)} جنيه'),
                    ],
                    if (order.rePricingReason != null &&
                        order.rePricingReason!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _InfoRow(
                          label: 'سبب التسعير',
                          value: order.rePricingReason!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Custom request
              if ((order.customRequestText != null &&
                      order.customRequestText!.isNotEmpty) ||
                  order.customRequestImage != null) ...[
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'طلب خاص من العميل',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      if (order.customRequestText != null &&
                          order.customRequestText!.isNotEmpty)
                        Text(order.customRequestText!),
                      if (order.customRequestImage != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ServiceCoverImage(
                            imageUrlRaw: order.customRequestImage,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Options
              if (order.options.isNotEmpty) ...[
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الخيارات المختارة',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      ...order.options.map((opt) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.optionGroupName,
                                        style: const TextStyle(
                                          color: AppColors.textHint,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        opt.optionName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'x${opt.quantity}',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary),
                                    ),
                                    if (opt.price > 0)
                                      Text(
                                        '+${opt.price.toStringAsFixed(2)}ج',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action buttons
              if (isRequest) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: provider.isRejecting
                            ? null
                            : () => _reject(provider),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: provider.isRejecting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2))
                            : const Text('رفض الطلب'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: provider.isApproving
                            ? null
                            : () => _approve(provider),
                        style: FilledButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: provider.isApproving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Text('قبول الطلب'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: provider.isRepricing
                        ? null
                        : () => _reprice(provider),
                    child: provider.isRepricing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('إرسال تسعير جديد للعميل'),
                  ),
                ),
              ] else if (isAcceptedOrLater) ...[
                // Update status section — only show transitions valid for current status
                Builder(builder: (context) {
                  final transitions = _validTransitions(order.status);
                  if (transitions.isEmpty) {
                    // No seller action available at this stage
                    return SoftCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'حالة الطلب الحالية',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getWaitingMessage(order.status),
                              style: const TextStyle(
                                  color: AppColors.textSecondary, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تحديث حالة الطلب',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedNextStatus,
                          hint: const Text('اختار الحالة الجديدة'),
                          items: transitions
                              .map((t) => DropdownMenuItem<String>(
                                    value: t['value'],
                                    child: Text(t['label']!),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedNextStatus = v),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: provider.isUpdatingStatus
                                ? null
                                : () => _updateStatus(provider),
                            child: provider.isUpdatingStatus
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('تحديث الحالة'),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle ??
                const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
