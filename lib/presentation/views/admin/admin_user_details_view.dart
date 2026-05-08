import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/admin_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/gradient_app_bar.dart';
import 'package:provider/provider.dart';

class AdminUserDetailsView extends StatefulWidget {
  const AdminUserDetailsView({super.key, required this.userId});

  final String userId;

  @override
  State<AdminUserDetailsView> createState() => _AdminUserDetailsViewState();
}

class _AdminUserDetailsViewState extends State<AdminUserDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = int.tryParse(widget.userId) ?? 0;
      context.read<AdminProvider>().fetchUserDetails(id);
    });
  }

  String _roleLabel(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'provider':
        return 'مزود خدمة';
      case 'admin':
        return 'مدير';
      case 'buyer':
        return 'عميل';
      case '2':
        return 'مزود خدمة';
      case '1':
        return 'مدير';
      case '0':
        return 'عميل';
      default:
        return raw ?? 'غير معروف';
    }
  }

  Future<void> _showBlockDialog(BuildContext context, AdminProvider provider, int userId) async {
    final reasonController = TextEditingController();
    DateTime? selectedDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حظر المستخدم',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'سبب الحظر',
                      border: OutlineInputBorder(),
                      hintText: 'مثال: مخالفة الشروط والأحكام',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('تاريخ انتهاء الحظر: ', style: TextStyle(color: AppColors.textSecondary)),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now().add(const Duration(days: 1)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'اختر تاريخ',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () async {
                            if (reasonController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('لازم تكتب سبب الحظر')),
                              );
                              return;
                            }
                            final until = selectedDate ?? DateTime.now().add(const Duration(days: 30));
                            Navigator.pop(ctx);
                            final (success, error) = await provider.blockUser(
                              userId,
                              reasonController.text.trim(),
                              until,
                            );
                            if (!context.mounted) return;
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم حظر المستخدم بنجاح')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error ?? 'حصل خطأ')),
                              );
                            }
                          },
                          child: const Text('تأكيد الحظر'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GradientAppBar(title: 'بيانات المستخدم #${widget.userId}'),
          Expanded(
            child: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.userDetails == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      final id = int.tryParse(widget.userId) ?? 0;
                      provider.fetchUserDetails(id);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          final user = provider.userDetails;
          if (user == null) {
            return const Center(child: Text('المستخدم مش موجود'));
          }

          final isBlocked = user['isBlocked'] == true;
          final userId = (user['id'] as num?)?.toInt() ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Avatar + name ──────────────────────────────────────
              SoftCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        backgroundImage: (user['imageUrl'] != null && (user['imageUrl'] as String).isNotEmpty)
                            ? NetworkImage(user['imageUrl'] as String)
                            : null,
                        child: (user['imageUrl'] == null || (user['imageUrl'] as String).isEmpty)
                            ? const Icon(Icons.person, color: AppColors.primary, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user['fullName']?.toString() ?? 'بدون اسم',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _roleLabel(user['role']?.toString()),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ── Contact info ───────────────────────────────────────
              SoftCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('معلومات الاتصال', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildRow('رقم الهاتف', user['phoneNumber']?.toString() ?? 'غير متوفر'),
                      const Divider(),
                      _buildRow('البريد الإلكتروني', user['email']?.toString() ?? 'غير متوفر'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ── Account info ───────────────────────────────────────
              SoftCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('بيانات الحساب', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildRow('الدور', _roleLabel(user['role']?.toString())),
                      const Divider(),
                      _buildRow(
                        'حالة الحساب',
                        isBlocked ? 'محظور' : 'نشط',
                        valueColor: isBlocked ? Colors.red : AppColors.statusActive,
                      ),
                      if (isBlocked) ...[
                        const Divider(),
                        _buildRow('سبب الحظر', user['blockReason']?.toString() ?? 'غير معروف'),
                        const Divider(),
                        _buildRow(
                          'محظور حتى',
                          user['blockedUntil'] != null
                              ? user['blockedUntil'].toString().split('T')[0]
                              : 'غير محدد',
                        ),
                        const Divider(),
                        _buildRow('حُظر بواسطة', user['blockedByAdmin']?.toString() ?? 'غير معروف'),
                      ],
                      const Divider(),
                      _buildRow(
                        'تاريخ التسجيل',
                        user['createdAt'] != null
                            ? user['createdAt'].toString().split('T')[0]
                            : 'غير معروف',
                      ),
                      const Divider(),
                      _buildRow(
                        'آخر تحديث',
                        user['updatedAt'] != null
                            ? user['updatedAt'].toString().split('T')[0]
                            : 'غير معروف',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ── Stats ──────────────────────────────────────────────
              SoftCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إحصائيات', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildRow('عدد الخدمات', '${(user['servicesCount'] as num?)?.toInt() ?? 0}'),
                      const Divider(),
                      _buildRow('عدد الطلبات', '${(user['ordersCount'] as num?)?.toInt() ?? 0}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('إجراءات الإدارة', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: provider.isUnblocking || provider.isBlocking
                          ? null
                          : () async {
                              if (isBlocked) {
                                final (success, error) = await provider.unblockUser(userId);
                                if (!context.mounted) return;
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم فك الحظر بنجاح')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error ?? 'حصل خطأ')),
                                  );
                                }
                              } else {
                                await _showBlockDialog(context, provider, userId);
                              }
                            },
                      icon: provider.isUnblocking || provider.isBlocking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(isBlocked ? Icons.check_circle : Icons.block),
                      label: Text(isBlocked ? 'فك الحظر' : 'حظر مؤقت'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isBlocked ? Colors.green : Colors.red,
                        side: BorderSide(color: isBlocked ? Colors.green : Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ميزة الإنذار غير متوفرة في هذا الإصدار')),
                        );
                      },
                      icon: const Icon(Icons.warning_amber),
                      label: const Text('إرسال إنذار'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor,
                overflow: TextOverflow.ellipsis,
              ),
              softWrap: true,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
