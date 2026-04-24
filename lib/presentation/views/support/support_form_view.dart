import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';

class SupportFormView extends StatefulWidget {
  const SupportFormView({super.key});

  @override
  State<SupportFormView> createState() => _SupportFormViewState();
}

class _SupportFormViewState extends State<SupportFormView> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _desc = TextEditingController();
  String _issue = 'مشكلة في الطلب';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.supportTitle),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () {
                final ticket =
                    DateTime.now().millisecondsSinceEpoch.remainder(1000000).toString();
                context.push('/support/confirmation?ticket=$ticket');
              },
              child: const Text(AppStrings.supportSubmit),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldSupportName,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldSupportEmail,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _issue,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldIssueType,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'مشكلة في الطلب',
                  child: Text('مشكلة في الطلب'),
                ),
                DropdownMenuItem(
                  value: 'مشكلة في الدفع',
                  child: Text('مشكلة في الدفع'),
                ),
                DropdownMenuItem(
                  value: 'اقتراح',
                  child: Text('اقتراح'),
                ),
              ],
              onChanged: (v) => setState(() => _issue = v ?? _issue),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldSupportDesc,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.attach_file),
              label: const Text(AppStrings.fieldAttachment),
            ),
          ],
        ),
      ),
    );
  }
}
