import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:confetti/confetti.dart';

class OrderPlacedView extends StatefulWidget {
  const OrderPlacedView({super.key});

  @override
  State<OrderPlacedView> createState() => _OrderPlacedViewState();
}

class _OrderPlacedViewState extends State<OrderPlacedView> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
            final isShort = constraints.maxHeight < 620;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: isShort ? 18 : 40),
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.statusActive.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 64,
                          color: AppColors.statusActive,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'تمام! طلبك اتسجل',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'هنبعتلك تحديث على الإشعارات لما الطلب يتحرك.\nمتقلقش.. كل حاجة هتمشي خطوة بخطوة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_active_outlined,
                              color: AppColors.primary.withValues(alpha: 0.9)),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'تابع حالة الطلب من صفحة "طلباتي".',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => context.go('/my-orders'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'شوف طلباتي',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.go('/home'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: AppColors.border),
                      ),
                      child: const Text(
                        'ارجع للرئيسية',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    SizedBox(height: isShort ? 10 : 18),
                  ],
                ),
              ),
            ),
          );
        },
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
            createParticlePath: drawStar,
          ),
        ),
          ],
        ),
      ),
    );
  }

  Path drawStar(Size size) {
    // A simple star path for confetti
    double degToRad(double deg) => deg * (3.1415926535897932 / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * 1.5 * 3.1415926535897932 / 180.0, // simplified star path not needed, standard shape used below
        halfWidth + externalRadius * 1.5 * 3.1415926535897932 / 180.0,
      );
    }
    path.close();
    return path;
  }
}
