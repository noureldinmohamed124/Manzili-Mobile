import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';

enum ManziliServiceStatus { active, paused, draft }

Future<ManziliServiceStatus?> showServiceStatusSheet(
  BuildContext context, {
  required ManziliServiceStatus current,
}) {
  return showModalBottomSheet<ManziliServiceStatus>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      ManziliServiceStatus selected = current;
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  AppStrings.statusSheetTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                RadioListTile<ManziliServiceStatus>(
                  title: const Text(AppStrings.statusActive),
                  value: ManziliServiceStatus.active,
                  groupValue: selected,
                  onChanged: (v) =>
                      setModalState(() => selected = v ?? selected),
                ),
                RadioListTile<ManziliServiceStatus>(
                  title: const Text(AppStrings.statusPaused),
                  value: ManziliServiceStatus.paused,
                  groupValue: selected,
                  onChanged: (v) =>
                      setModalState(() => selected = v ?? selected),
                ),
                RadioListTile<ManziliServiceStatus>(
                  title: const Text(AppStrings.statusDraft),
                  value: ManziliServiceStatus.draft,
                  groupValue: selected,
                  onChanged: (v) =>
                      setModalState(() => selected = v ?? selected),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(AppStrings.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, selected),
                        child: const Text(AppStrings.confirm),
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
