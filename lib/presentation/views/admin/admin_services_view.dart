import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class AdminServicesView extends StatefulWidget {
  const AdminServicesView({super.key});

  @override
  State<AdminServicesView> createState() => _AdminServicesViewState();
}

class _AdminServicesViewState extends State<AdminServicesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الخدمات'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (adminProvider.errorMessage != null) {
            return Center(
              child: Text(adminProvider.errorMessage!, style: const TextStyle(color: AppColors.error)),
            );
          }

          final services = adminProvider.servicesResponse?.items ?? [];

          if (services.isEmpty) {
            return const Center(child: Text('لا توجد خدمات'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final s = services[index];
              final isPending = s.status == 'Pending' || s.status == 'مراجعة';

              return SoftCard(
                onTap: () => context.push('/admin/services/details/${s.id}'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.design_services, color: AppColors.textHint),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('بواسطة: ${s.providerName.isNotEmpty ? s.providerName : "غير معروف"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPending ? AppColors.statusPending.withValues(alpha: 0.1) : AppColors.statusActive.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.status,
                          style: TextStyle(
                            color: isPending ? AppColors.statusPending : AppColors.statusActive,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
