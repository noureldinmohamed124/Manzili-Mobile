import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/data/models/order_models.dart';
import 'package:manzili_mobile/presentation/providers/orders_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// طلباتي — the pre-payment lifecycle screen.
///
/// Tab 1 "في الانتظار"     → status: Request
///   Buyer sent a request, waiting for seller to accept/reject/reprice.
///
/// Tab 2 "بانتظار الدفع"   → status: Accepted
///   Seller approved. Buyer must upload payment proof.
///   Shows "ادفع دلوقتي" per order + "ادفع الكل" sticky bar.
///
/// Tab 3 "جاري المراجعة"   → status: PendingPaymentVerification
///   Proof uploaded. Waiting for admin to confirm transfer.
///   Once admin confirms → status becomes Paid → order moves to أوردراتي.
///
/// Tab 4 "مرفوضة"          → status: Rejected
class RequestsListView extends StatefulWidget {
  const RequestsListView({super.key});

  @override
  State<RequestsListView> createState() => _RequestsListViewState();
}

class _RequestsListViewState extends State<RequestsListView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static String _statusAr(String s) {
    switch (s.toLowerCase()) {
      case 'request':                    return 'في الانتظار';
      case 'accepted':                   return 'مقبول';
      case 'pendingpaymentverification': return 'جاري مراجعة الدفع';
      case 'rejected':                   return 'مرفوض';
      default:                           return s;
    }
  }

  static Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'request':                    return AppColors.statusPending;
      case 'accepted':                   return AppColors.statusActive;
      case 'pendingpaymentverification': return Colors.deepOrange;
      case 'rejected':                   return AppColors.error;
      default:                           return AppColors.statusInactive;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Gradient header ────────────────────────────────────────────
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'طلباتي',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.read<OrdersProvider>().fetchOrders(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.refresh_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: 'في الانتظار'),
                      Tab(text: 'بانتظار الدفع'),
                      Tab(text: 'جاري المراجعة'),
                      Tab(text: 'مرفوضة'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ── Body ──────────────────────────────────────────────────────
          Expanded(
            child: Consumer<OrdersProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null && provider.orders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.wifi_off_rounded,
                                size: 48, color: AppColors.error),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => provider.fetchOrders(),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('جرّب تاني'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final pending = provider.orders
                    .where((o) => o.status.toLowerCase() == 'request')
                    .toList();
                final accepted = provider.orders
                    .where((o) => o.status.toLowerCase() == 'accepted')
                    .toList();
                final reviewing = provider.orders
                    .where((o) =>
                        o.status.toLowerCase() ==
                        'pendingpaymentverification')
                    .toList();
                final rejected = provider.orders
                    .where((o) => o.status.toLowerCase() == 'rejected')
                    .toList();

                return Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          RefreshIndicator(
                            onRefresh: () =>
                                context.read<OrdersProvider>().fetchOrders(),
                            child: _buildList(
                              orders: pending,
                              emptyMessage: 'مفيش طلبات في الانتظار دلوقتي',
                              emptyIcon: Icons.hourglass_empty_rounded,
                              statusColor: _statusColor('request'),
                              statusLabel: _statusAr('request'),
                            ),
                          ),
                          RefreshIndicator(
                            onRefresh: () =>
                                context.read<OrdersProvider>().fetchOrders(),
                            child: _buildAcceptedTab(accepted),
                          ),
                          RefreshIndicator(
                            onRefresh: () =>
                                context.read<OrdersProvider>().fetchOrders(),
                            child: _buildList(
                              orders: reviewing,
                              emptyMessage:
                                  'مفيش طلبات جاري مراجعة دفعها',
                              emptyIcon: Icons.pending_actions_rounded,
                              statusColor: _statusColor(
                                  'pendingpaymentverification'),
                              statusLabel:
                                  _statusAr('pendingpaymentverification'),
                              trailingBadge: (o) => _reviewingBadge(),
                            ),
                          ),
                          RefreshIndicator(
                            onRefresh: () =>
                                context.read<OrdersProvider>().fetchOrders(),
                            child: _buildList(
                              orders: rejected,
                              emptyMessage: 'مفيش طلبات مرفوضة',
                              emptyIcon: Icons.cancel_outlined,
                              statusColor: _statusColor('rejected'),
                              statusLabel: _statusAr('rejected'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (accepted.isNotEmpty) _buildPayAllBar(context, accepted),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: accepted orders with pay button ──────────────────────────────────

  Widget _buildAcceptedTab(List<OrderListItem> orders) {
    if (orders.isEmpty) {
      return _emptyState(
        message: 'مفيش طلبات بانتظار الدفع دلوقتي',
        icon: Icons.payment_outlined,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final o = orders[i];
        return _OrderCard(
          order: o,
          statusLabel: _statusAr(o.status),
          statusColor: _statusColor(o.status),
          action: FilledButton.icon(
            onPressed: () => _showPaymentSheet(context, orderIds: [o.id]),
            icon: const Icon(Icons.payment, size: 16),
            label: const Text('ادفع دلوقتي'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.statusActive,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPayAllBar(BuildContext context, List<OrderListItem> orders) {
    final total = orders.fold(0.0, (s, o) => s + o.totalPrice);
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${orders.length} طلب بانتظار الدفع',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                Text(
                  '${total.toStringAsFixed(2)} جنيه',
                  style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => _showPaymentSheet(
              context,
              orderIds: orders.map((o) => o.id).toList(),
            ),
            icon: const Icon(Icons.payment, size: 18),
            label: const Text('ادفع الكل'),
          ),
        ],
      ),
    );
  }

  // ── Generic list builder ────────────────────────────────────────────────────

  Widget _buildList({
    required List<OrderListItem> orders,
    required String emptyMessage,
    required IconData emptyIcon,
    required Color statusColor,
    required String statusLabel,
    Widget Function(OrderListItem)? trailingBadge,
  }) {
    if (orders.isEmpty) {
      return _emptyState(message: emptyMessage, icon: emptyIcon);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final o = orders[i];
        return _OrderCard(
          order: o,
          statusLabel: statusLabel,
          statusColor: statusColor,
          action: trailingBadge?.call(o),
        );
      },
    );
  }

  Widget _reviewingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 14, color: Colors.deepOrange),
          SizedBox(width: 4),
          Text(
            'جاري مراجعة الدفع',
            style: TextStyle(fontSize: 12, color: Colors.deepOrange, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({required String message, required IconData icon}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.go('/home'),
            child: const Text('تصفح الخدمات'),
          ),
        ],
      ),
    );
  }

  // ── Payment sheet ───────────────────────────────────────────────────────────

  void _showPaymentSheet(BuildContext context, {required List<int> orderIds}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PaymentProofSheet(
        orderIds: orderIds,
        onDone: () {
          Navigator.pop(ctx);
          context.read<OrdersProvider>().fetchOrders();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال إثبات الدفع ✅ — جاري مراجعة التحويل')),
          );
        },
      ),
    );
  }
}

// ── Shared order card ─────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.statusLabel,
    required this.statusColor,
    this.action,
  });

  final OrderListItem order;
  final String statusLabel;
  final Color statusColor;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final dateStr = order.createdAt != null
        ? DateFormat('dd MMM yyyy', 'ar').format(order.createdAt!)
        : '';
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.serviceName,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11, color: statusColor, fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'بواسطة: ${order.providerName}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          if (order.customizationDetails.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              order.customizationDetails,
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.totalPrice.toStringAsFixed(2)} جنيه',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 16,
                    ),
                  ),
                  if (dateStr.isNotEmpty)
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                    ),
                ],
              ),
              if (action != null) action!,
            ],
          ),
        ],
      ),
    );
  }
}

// ── Payment Proof Bottom Sheet ────────────────────────────────────────────────

class _PaymentProofSheet extends StatefulWidget {
  const _PaymentProofSheet({required this.orderIds, required this.onDone});
  final List<int> orderIds;
  final VoidCallback onDone;

  @override
  State<_PaymentProofSheet> createState() => _PaymentProofSheetState();
}

class _PaymentProofSheetState extends State<_PaymentProofSheet> {
  XFile? _receipt;
  final _notes = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_receipt == null) {
      setState(() => _error = 'ارفع صورة الإيصال الأول');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    final ok = await context.read<OrdersProvider>().submitPaymentProof(
      targetOrderIds: widget.orderIds,
      paymentScreenshotPath: _receipt!.path,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      widget.onDone();
    } else {
      setState(() {
        _error = context.read<OrdersProvider>().errorMessage ?? 'فشل إرسال الإيصال';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMultiple = widget.orderIds.length > 1;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isMultiple
                ? 'دفع ${widget.orderIds.length} طلبات'
                : 'دفع طلب #${widget.orderIds.first}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          // Instapay info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'حوّل المبلغ على manzili@instapay ثم ارفع صورة الإيصال هنا',
                    style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
            ),
          // Image picker
          GestureDetector(
            onTap: () async {
              final f = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (f != null) setState(() => _receipt = f);
            },
            child: Container(
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _receipt != null ? AppColors.primary : AppColors.border,
                  width: _receipt != null ? 2 : 1,
                ),
              ),
              child: _receipt != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.statusActive, size: 22),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _receipt!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600, color: AppColors.statusActive,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            final f = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (f != null) setState(() => _receipt = f);
                          },
                          child: const Text('تغيير'),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, size: 30, color: AppColors.textSecondary),
                        SizedBox(height: 6),
                        Text(
                          'اضغط لاختيار صورة الإيصال',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(
              labelText: 'ملاحظات (اختياري)',
              hintText: 'رقم المعاملة أو أي تفاصيل زيادة…',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'إرسال إثبات الدفع',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}
