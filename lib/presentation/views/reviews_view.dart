import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/data/models/service_models.dart';
import 'package:manzili_mobile/presentation/providers/services_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/widgets/responsive_max_width.dart';

class ReviewsView extends StatefulWidget {
  const ReviewsView({
    super.key,
    this.serviceId,
  });

  final int? serviceId;

  @override
  State<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<ReviewsView> {
  ServiceItem? _service;
  bool _loading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    final id = widget.serviceId ?? 0;
    if (id > 0) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final provider = context.read<ServicesProvider>();
        final item = await provider.getServiceById(id);
        if (!mounted) return;
        setState(() {
          _service = item;
          _loading = false;
          _loadError = item == null ? provider.errorMessage : null;
        });
      });
    }
  }

  String get _title => _service?.title ?? 'خدمة';

  Map<int, int> _starCounts(List<ServiceReview> reviews) {
    final m = {for (var s = 1; s <= 5; s++) s: 0};
    for (final r in reviews) {
      final k = r.rating.round().clamp(1, 5);
      m[k] = (m[k] ?? 0) + 1;
    }
    return m;
  }

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
                child: _buildBody(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final id = widget.serviceId ?? 0;
    if (id <= 0) {
      return Center(
        child: Padding(
          padding: ResponsiveHelper.responsivePadding(context),
          child: Text(
            'مفيش خدمة محددة.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 15),
            ),
          ),
        ),
      );
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_service == null) {
      return Center(
        child: Padding(
          padding: ResponsiveHelper.responsivePadding(context),
          child: Text(
            _loadError ?? 'مش قدرنا نحمّل تفاصيل الخدمة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 15),
            ),
          ),
        ),
      );
    }

    final service = _service!;
    final reviews = service.reviews ?? [];
    final reviewCount = service.provider?.reviewsNo ?? reviews.length;
    final avg = service.rating;

    return SingleChildScrollView(
      padding: ResponsiveHelper.responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingSummary(context, avg, reviewCount, reviews),
          _buildIndividualReviews(context, reviews),
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 20)),
        ],
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
                  _title,
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

  Widget _buildRatingSummary(
    BuildContext context,
    num avg,
    int reviewCount,
    List<ServiceReview> reviews,
  ) {
    final fullStars = avg.round().clamp(0, 5);
    final counts = reviews.isNotEmpty ? _starCounts(reviews) : null;
    final totalForBars = reviews.length;

    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.responsiveSpacingCompat(context, mobile: 22)),
      padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacingCompat(context, mobile: 20)),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (counts != null && totalForBars > 0) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var stars = 5; stars >= 1; stars--) ...[
                        if (stars < 5)
                          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
                        _buildRatingBreakdownItem(
                          context,
                          stars,
                          counts[stars] ?? 0,
                          totalForBars,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 24)),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      avg.toDouble().toStringAsFixed(1),
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
                          index < fullStars ? Icons.star : Icons.star_border,
                          color: AppColors.primary,
                          size: ResponsiveHelper.responsiveValueCompat(context, mobile: 24.0),
                        );
                      }),
                    ),
                    SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
                    Text(
                      '$reviewCount تقييم',
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
          SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 24)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success.withValues(alpha: 0.5),
                padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveValueCompat(context, mobile: 12.0)),
                ),
              ),
              child: Text(
                'اكتب تقييم (قريباً)',
                style: TextStyle(
                  fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 16),
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
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

  Widget _buildIndividualReviews(BuildContext context, List<ServiceReview> reviews) {
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
          if (reviews.isEmpty)
            Text(
              'مافيش آراء متاحة حالياً. لو السيرفر بعت قائمة تقييمات مع تفاصيل الخدمة، هتظهر هنا.',
              style: TextStyle(
                fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            )
          else
            ...reviews.map((r) {
              return Padding(
                padding: EdgeInsets.only(bottom: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
                child: _buildReviewCard(
                  context: context,
                  name: r.reviewerName ?? 'مستخدم',
                  date: r.createdAt ?? '',
                  rating: r.rating.round().clamp(0, 5),
                  review: r.comment ?? '',
                ),
              );
            }),
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
        color: AppColors.surfaceMuted,
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppColors.primary,
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
              if (date.isNotEmpty) ...[
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
            ],
          ),
          if (review.isNotEmpty) ...[
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
        ],
      ),
    );
  }
}
