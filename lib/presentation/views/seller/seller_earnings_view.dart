import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/strings/app_strings.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';

/// Screen 7 — Earnings (mock charts + filters).
class SellerEarningsView extends StatefulWidget {
  const SellerEarningsView({super.key});

  @override
  State<SellerEarningsView> createState() => _SellerEarningsViewState();
}

class _SellerEarningsViewState extends State<SellerEarningsView> {
  int _filter = 1; // 0 day 1 week 2 month
  bool _loading = false;
  bool _empty = false;

  @override
  Widget build(BuildContext context) {
    final filters = [
      AppStrings.filterToday,
      AppStrings.filterWeek,
      AppStrings.filterMonth,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.earningsTitle),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _loading = !_loading;
                _empty = false;
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _empty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      AppStrings.errAnalyticsEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final sel = _filter == i;
                          return ChoiceChip(
                            label: Text(filters[i]),
                            selected: sel,
                            onSelected: (_) => setState(() => _filter = i),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.25,
                      children: const [
                        _MetricCard(
                          title: AppStrings.cardGross,
                          value: '٣٬٢٥٠ ج.م',
                          icon: Icons.payments_outlined,
                          color: AppColors.statusActive,
                        ),
                        _MetricCard(
                          title: AppStrings.cardPending,
                          value: '٤٢٠ ج.م',
                          icon: Icons.hourglass_bottom_rounded,
                          color: AppColors.statusPending,
                        ),
                        _MetricCard(
                          title: AppStrings.cardOrdersCount,
                          value: '٣٤',
                          icon: Icons.receipt_long_outlined,
                          color: AppColors.primary,
                        ),
                        _MetricCard(
                          title: AppStrings.cardAvgOrder,
                          value: '٩٥ ج.م',
                          icon: Icons.trending_up_rounded,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'مخطط بسيط',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, c) {
                              return SizedBox(
                                height: 120,
                                width: c.maxWidth,
                                child: CustomPaint(
                                  painter: _BarsPainter(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.topServices,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SoftCard(
                      child: Column(
                        children: const [
                          _TopRow('كيكة فراولة', '٤٥٪'),
                          Divider(),
                          _TopRow('عيش بلدي', '٣٠٪'),
                          Divider(),
                          _TopRow('مكرونة بشاميل', '٢٥٪'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.recentEarnings,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SoftCard(
                      child: Column(
                        children: const [
                          _EarnRow('اليوم', '+ ١٢٠ ج.م'),
                          Divider(),
                          _EarnRow('أمس', '+ ٨٥ ج.م'),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary.withValues(alpha: 0.35);
    final w = size.width / 7;
    final heights = [0.4, 0.55, 0.35, 0.7, 0.5, 0.65, 0.45];
    for (var i = 0; i < heights.length; i++) {
      final h = size.height * heights[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(4 + i * w, size.height - h, w - 8, h),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopRow extends StatelessWidget {
  const _TopRow(this.name, this.pct);
  final String name;
  final String pct;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600))),
        Text(pct, style: const TextStyle(color: AppColors.primary)),
      ],
    );
  }
}

class _EarnRow extends StatelessWidget {
  const _EarnRow(this.day, this.amount);
  final String day;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(day)),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
