import 'package:flutter/material.dart';
import 'food_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';

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
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22),
            vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onTitleTap,
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 20, tablet: 22),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (titleIcon != null) ...[
                      SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
                      Icon(
                        titleIcon,
                        size: ResponsiveHelper.responsiveValueCompat(context, mobile: 20.0),
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
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: ResponsiveHelper.scaleValueFromContext(context, 280.0, min: 260.0, max: 320.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(right: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22)),
            itemCount: foodItems.length,
            itemBuilder: (context, index) => foodItems[index],
          ),
        ),
      ],
    );
  }
}
