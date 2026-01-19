import 'package:flutter/material.dart';
import 'sort_option.dart';

class SortModal extends StatelessWidget {
  final String selectedOption;
  final Function(String) onOptionSelected;

  const SortModal({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'ترتيب بواسطة السعر',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
          Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
          SortOption(
            text: 'الافتراضي',
            isSelected: selectedOption == 'الافتراضي',
            onTap: () => onOptionSelected('الافتراضي'),
          ),
          SortOption(
            text: 'من الأقل',
            isSelected: selectedOption == 'من الأقل',
            onTap: () => onOptionSelected('من الأقل'),
          ),
          SortOption(
            text: 'من الأعلى',
            isSelected: selectedOption == 'من الأعلى',
            onTap: () => onOptionSelected('من الأعلى'),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
