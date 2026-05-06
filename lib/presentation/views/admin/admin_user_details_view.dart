import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

import 'package:manzili_mobile/presentation/providers/admin_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('بيانات المستخدم #${widget.userId}'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.userDetails == null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          final user = provider.userDetails;
          if (user == null) {
            return const Center(child: Text('المستخدم مش موجود'));
          }

          final isBlocked = user['isBlocked'] == true;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SoftCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        backgroundImage: user['imageUrl'] != null ? NetworkImage(user['imageUrl']) : null,
                        child: user['imageUrl'] == null ? const Icon(Icons.person, color: AppColors.primary, size: 40) : null,
                      ),
                      const SizedBox(height: 16),
                      Text(user['fullName'] ?? 'بدون اسم', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(user['role'] ?? 'عميل', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SoftCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('معلومات الاتصال', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildRow('رقم الهاتف', user['phoneNumber'] ?? 'غير متوفر'),
                      const Divider(),
                      _buildRow('البريد الإلكتروني', user['email'] ?? 'غير متوفر'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SoftCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إحصائيات', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildRow('تاريخ التسجيل', user['createdAt'] != null ? user['createdAt'].toString().split('T')[0] : 'غير معروف'),
                      const Divider(),
                      _buildRow('حالة الحساب', isBlocked ? 'محظور' : 'نشط'),
                      if (isBlocked) ...[
                        const Divider(),
                        _buildRow('سبب الحظر', user['blockReason'] ?? 'غير معروف'),
                      ]
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
                                final (success, error) = await provider.unblockUser(user['id']);
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم فك الحظر بنجاح')),
                                  );
                                } else if (context.mounted && error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                }
                              } else {
                                final (success, error) = await provider.blockUser(
                                  user['id'],
                                  'مخالفة الشروط',
                                  DateTime.now().add(const Duration(days: 30)),
                                );
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم حظر المستخدم بنجاح')),
                                  );
                                } else if (context.mounted && error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                }
                              }
                            },
                      icon: provider.isUnblocking || provider.isBlocking
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
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
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
