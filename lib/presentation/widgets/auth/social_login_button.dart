import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialLoginButton extends StatelessWidget {
  final String asset;

  const SocialLoginButton({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Center(
        child: asset.endsWith('.svg')
            ? SvgPicture.asset(
                asset,
                width: 50,
                height: 50,
              )
            : Image.asset(
                asset,
                width: 50,
                height: 50,
              ),
      ),
    );
  }
}
