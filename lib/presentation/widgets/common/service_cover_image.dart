import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/network/api_image_url.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';

/// Network image from API ([resolveServiceImageUrl]); no bundled asset fallbacks.
class ServiceCoverImage extends StatelessWidget {
  const ServiceCoverImage({
    super.key,
    this.imageUrlRaw,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String? imageUrlRaw;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = resolveServiceImageUrl(imageUrlRaw);
    final placeholder = _ServiceImagePlaceholder(width: width, height: height);
    if (url == null) {
      return placeholder;
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

class _ServiceImagePlaceholder extends StatelessWidget {
  const _ServiceImagePlaceholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final box = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceMuted,
            AppColors.primary.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textHint,
          size: _iconSizeFor(height),
        ),
      ),
    );
    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: box);
    }
    return SizedBox.expand(child: box);
  }

  double _iconSizeFor(double? h) {
    if (h == null) return 40;
    return (h * 0.22).clamp(28.0, 56.0);
  }
}
