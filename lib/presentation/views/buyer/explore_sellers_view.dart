import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class ExploreSellersView extends StatefulWidget {
  const ExploreSellersView({super.key});

  @override
  State<ExploreSellersView> createState() => _ExploreSellersViewState();
}

class _ExploreSellersViewState extends State<ExploreSellersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ServicesProvider>();
      if (p.services.isEmpty && !p.isLoading) {
        p.fetchServices(page: 1, pageSize: 50);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.exploreSellers),
      ),
      body: Consumer<ServicesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.services.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = provider.services;
          final Map<String, dynamic> sellersMap = {};
          
          for (final s in services) {
            final name = s.providerName.trim();
            if (name.isNotEmpty && !sellersMap.containsKey(name)) {
              sellersMap[name] = {
                'name': name,
                'rating': s.provider?.rating ?? s.rating,
                'serviceId': s.id, // In case we want to navigate directly
              };
            }
          }

          final sellers = sellersMap.values.toList();

          if (sellers.isEmpty) {
             return const Center(
               child: Text(
                 'لا يوجد بائعين حالياً',
                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
               )
             );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sellers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final seller = sellers[i];
              final name = seller['name'] as String;
              final rating = seller['rating'] as num;
              
              return SoftCard(
                onTap: () {
                  // Navigate to services view filtered by this seller's name
                  context.push('/seller-services?q=$name');
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: const Icon(Icons.storefront_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تقييم ${rating.toStringAsFixed(1)} · شحن سريع من نفس المنطقة',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
