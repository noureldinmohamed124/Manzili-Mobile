import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';

class SellerOfferEditorView extends StatefulWidget {
  const SellerOfferEditorView({super.key});

  @override
  State<SellerOfferEditorView> createState() => _SellerOfferEditorViewState();
}

class _SellerOfferEditorViewState extends State<SellerOfferEditorView> {
  final _title = TextEditingController();
  final _discount = TextEditingController();
  final _notes = TextEditingController();
  String _service = 'كيكة فراولة';
  DateTimeRange? _range;

  @override
  void dispose() {
    _title.dispose();
    _discount.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.offerEditorTitle),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () {
                final d = int.tryParse(_discount.text);
                if (d == null || d < 1 || d > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الخصم لازم يكون بين ١ و ١٠٠٪'),
                    ),
                  );
                  return;
                }
                if (_range == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('اختار تواريخ صحيحة للعرض'),
                    ),
                  );
                  return;
                }
                context.pop();
              },
              child: const Text('احفظ العرض'),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldOfferTitle,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _service,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldLinkedService,
              ),
              items: const [
                DropdownMenuItem(value: 'كيكة فراولة', child: Text('كيكة فراولة')),
                DropdownMenuItem(value: 'عيش بلدي', child: Text('عيش بلدي')),
              ],
              onChanged: (v) => setState(() => _service = v ?? _service),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _discount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldDiscount,
                hintText: '١–١٠٠',
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(AppStrings.fieldDates),
              subtitle: Text(
                _range == null
                    ? 'اختار من / لحد'
                    : '${_range!.start.toLocal()} → ${_range!.end.toLocal()}',
              ),
              trailing: const Icon(Icons.date_range),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: now.subtract(const Duration(days: 1)),
                  lastDate: now.add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _range = picked);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldNotes,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
