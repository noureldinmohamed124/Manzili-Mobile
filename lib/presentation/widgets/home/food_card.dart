import 'package:flutter/material.dart';
import 'package:manzili_mobile/presentation/widgets/common/service_cover_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';

class FoodCard extends StatelessWidget {
  final String? networkImageUrl;
  final String name;
  final String sellerName;
  final double price;
  final double? originalPrice;
  final double rating;
  final String? badge;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const FoodCard({
    super.key,
    this.networkImageUrl,
    required this.name,
    required this.sellerName,
    required this.price,
    this.originalPrice,
    required this.rating,
    this.badge,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = ResponsiveHelper.clampScaledValue(
          context,
          45,
          min: 160.0,
          max: 220.0,
        );
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: cardWidth,
            margin: EdgeInsetsDirectional.only(
              start: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveValueCompat(context, mobile: 16.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(ResponsiveHelper.responsiveValueCompat(context, mobile: 16.0)),
                  ),
                  child: _buildImage(context),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacingCompat(context, mobile: 6)),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: ResponsiveHelper.responsiveValueCompat(context, mobile: 18.0),
                        color: isFavorite ? Colors.red : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8),
                    right: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8),
                        vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 4),
                      ),
                      decoration: BoxDecoration(
                        color: _getBadgeColor(badge!),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveValueCompat(context, mobile: 8.0)),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 10),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8),
                  left: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 6),
                      vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 4),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveValueCompat(context, mobile: 8.0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: ResponsiveHelper.responsiveValueCompat(context, mobile: 12.0),
                          color: Colors.amber,
                        ),
                        SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 4)),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 11),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 4)),
                  Text(
                    'بواسطة $sellerName',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 12),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
                  Row(
                    children: [
                      Text(
                        '${price.toInt()} جنيه',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 16),
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      if (originalPrice != null) ...[
                        SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
                        Text(
                          '${originalPrice!.toInt()}',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildImage(BuildContext context) {
    final height = ResponsiveHelper.clampScaledValue(
      context,
      35,
      min: 120.0,
      max: 180.0,
    );

    return ServiceCoverImage(
      imageUrlRaw: networkImageUrl,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
    );
  }

  Color _getBadgeColor(String badge) {
    if (badge.contains('خصم') || badge == 'أفضل') {
      return Colors.red;
    } else if (badge == 'مرشحه') {
      return Colors.amber.shade700;
    }
    return AppColors.primary;
  }
}
