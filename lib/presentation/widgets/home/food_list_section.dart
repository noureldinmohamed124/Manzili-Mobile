import 'package:flutter/material.dart';
import 'food_card.dart';
import '../../../../core/theme/app_colors.dart';

class FoodListSection extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final Color? titleIconColor;
  final String? viewAllText;
  final VoidCallback? onViewAllTap;
  final VoidCallback? onTitleTap;
  final List<FoodCard> foodItems;

  const FoodListSection({
    super.key,
    required this.title,
    this.titleIcon,
    this.titleIconColor,
    this.viewAllText,
    this.onViewAllTap,
    this.onTitleTap,
    required this.foodItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onTitleTap,
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (titleIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        titleIcon,
                        size: 20,
                        color: titleIconColor ?? AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
              if (viewAllText != null)
                TextButton(
                  onPressed: onViewAllTap,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    viewAllText!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 22),
            itemCount: foodItems.length,
            itemBuilder: (context, index) => foodItems[index],
          ),
        ),
      ],
    );
  }
}
