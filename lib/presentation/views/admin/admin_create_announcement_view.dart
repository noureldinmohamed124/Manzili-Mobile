import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

class AdminCreateAnnouncementView extends StatelessWidget {
  const AdminCreateAnnouncementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إعلان جديد'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('عنوان الإعلان', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const TextField(
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text('محتوى الإعلان', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text('الجمهور المستهدف', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    value: 'الجميع',
                    items: const [
                      DropdownMenuItem(value: 'الجميع', child: Text('الجميع (عملاء، بائعين، مناديب)')),
                      DropdownMenuItem(value: 'العملاء', child: Text('العملاء فقط')),
                      DropdownMenuItem(value: 'البائعين', child: Text('البائعين فقط')),
                      DropdownMenuItem(value: 'المناديب', child: Text('المناديب فقط')),
                    ],
                    onChanged: (val) {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              // TODO: API Call to create announcement
              context.pop();
            },
            child: const Text('إرسال التنبيه'),
          ),
        ],
      ),
    );
  }
}
