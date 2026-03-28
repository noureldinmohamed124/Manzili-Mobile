import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/section_header.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class SellerTemplatesView extends StatelessWidget {
  const SellerTemplatesView({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = [
      'بوست عرض سريع',
      'إعلان توصيل',
      'ترحيب بعملاء جدد',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.templatesTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: AppStrings.templatesTitle,
            subtitle: AppStrings.templatesSubtitle,
          ),
          ...templates.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SoftCard(
                child: Row(
                  children: [
                    const Icon(Icons.article_outlined, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
