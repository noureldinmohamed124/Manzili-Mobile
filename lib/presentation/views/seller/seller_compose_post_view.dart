import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';

class SellerComposePostView extends StatefulWidget {
  const SellerComposePostView({super.key});

  @override
  State<SellerComposePostView> createState() => _SellerComposePostViewState();
}

class _SellerComposePostViewState extends State<SellerComposePostView> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _tags = TextEditingController();
  String _visibility = 'الكل';
  DateTime? _schedule;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.composePostTitle),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم النشر (محليًا)')),
                      );
                      context.pop();
                    },
                    child: const Text(AppStrings.ctaPublish),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('اتحفظت كمسودة')),
                      );
                      context.pop();
                    },
                    child: const Text(AppStrings.ctaSaveDraft),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: AppStrings.fieldPostTitle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _body,
              minLines: 4,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldPostBody,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.perm_media_outlined),
              label: const Text(AppStrings.fieldMedia),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldTags,
                hintText: '#حلويات #منزلي',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _visibility,
              decoration: const InputDecoration(labelText: AppStrings.fieldVisibility),
              items: const [
                DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                DropdownMenuItem(value: 'المتابعين', child: Text('المتابعين')),
              ],
              onChanged: (v) => setState(() => _visibility = v ?? _visibility),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(AppStrings.fieldSchedule),
              subtitle: Text(
                _schedule?.toString() ?? 'اختياري — اضغط للجدولة',
              ),
              trailing: const Icon(Icons.schedule),
              onTap: () async {
                final t = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (t != null) setState(() => _schedule = t);
              },
            ),
          ],
        ),
      ),
    );
  }
}
