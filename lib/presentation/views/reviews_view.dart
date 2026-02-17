import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/widgets/responsive_max_width.dart';

class ReviewsView extends StatelessWidget {
  final String productName;
  
  const ReviewsView({
    super.key,
    this.productName = 'كوكيز بالشكولاتة',
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ResponsiveMaxWidth(
                child: SingleChildScrollView(
                  padding: ResponsiveHelper.responsivePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingSummary(context),
                      _buildIndividualReviews(context),
                      _buildShowMore(context),
                      SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 20)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8),
        left: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16),
        right: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16),
        bottom: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16),
      ),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التقييمات و الآراء',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 20, tablet: 22),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 4)),
                Text(
                  productName,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22)),
      padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacingCompat(context, mobile: 20)),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRatingBreakdownItem(context, 5, 3, 5),
                    SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
                    _buildRatingBreakdownItem(context, 4, 1, 5),
                    SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
                    _buildRatingBreakdownItem(context, 3, 1, 5),
                    SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
                    _buildRatingBreakdownItem(context, 2, 0, 5),
                    SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
                    _buildRatingBreakdownItem(context, 1, 0, 5),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 24)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '4.4',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 48, tablet: 52, desktop: 56),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_border,
                        color: AppColors.primary,
                        size: ResponsiveHelper.responsiveValueCompat(context, mobile: 24.0),
                      );
                    }),
                  ),
                  SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
                  Text(
                    '5 تقييم',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 24)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveValueCompat(context, mobile: 12.0)),
                ),
              ),
              child: Text(
                'اكتب تقييم',
                style: TextStyle(
                  fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 16),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdownItem(BuildContext context, int stars, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;
    
    return Row(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
        // Wrap the bar + stars in Expanded so they can shrink on small widths
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: ResponsiveHelper.responsiveValueCompat(context, mobile: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: AppColors.primary,
                      size: ResponsiveHelper.responsiveValueCompat(context, mobile: 16.0),
                    ),
                    Text(
                      ' $stars',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualReviews(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الآراء',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 18, tablet: 20),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
          _buildReviewCard(
            context: context,
            name: 'ليلى أحمد',
            date: '12-11-2025',
            rating: 4,
            review: 'حب هذا المنتج حقا! الشحن سريع والجودة ممتازة. خدمة العملاء كانت مفيدة جدا عندما كان لدي أسئلة. أوصي به للجميع!',
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
          _buildReviewCard(
            context: context,
            name: 'ليلى أحمد',
            date: '12-11-2025',
            rating: 4,
            review: 'حب هذا المنتج حقا! الشحن سريع والجودة ممتازة. خدمة العملاء كانت مفيدة جدا عندما كان لدي أسئلة. أوصي به للجميع!',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required BuildContext context,
    required String name,
    required String date,
    required int rating,
    required String review,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0, tablet: 44.0),
                      height: ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0, tablet: 44.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
                    Expanded(
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
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                color: AppColors.primary,
                                size: ResponsiveHelper.responsiveValueCompat(context, mobile: 16.0),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
              Text(
                date,
                style: TextStyle(
                  fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 12),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
          Text(
            review,
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowMore(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22)),
        child: GestureDetector(
          onTap: () {},
          child: Text(
            'عرض المزيد',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 16),
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}
