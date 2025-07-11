import 'dart:ui';

import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum Intensity { superLow, low, medium, high, superHigh, megaHigh, ultraHigh }

enum BlurType { blur, opacity, gradient, filtered }

extension BlurIntensityValue on Intensity {
  double get value {
    switch (this) {
      case Intensity.superLow:
        return 1.0;
      case Intensity.low:
        return 5.0;
      case Intensity.medium:
        return 10.0;
      case Intensity.high:
        return 20.0;
      case Intensity.superHigh:
        return 40.0;
      case Intensity.megaHigh:
        return 80.0;
      case Intensity.ultraHigh:
        return 120.0;
    }
  }
}

class Blur extends StatelessWidget {
  final Widget child;
  final BlurType? type;
  final BorderRadius? borderRadius;
  final Color? blurColor;
  final double? intensity;
  final double? opacity;
  const Blur({
    super.key,
    required this.child,
    this.borderRadius,
    this.blurColor,
    this.intensity = 5,
    this.type = BlurType.blur,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: switch (type) {
        BlurType.blur => BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: intensity!,
            sigmaY: intensity!,
            tileMode: TileMode.mirror,
          ),
          child: Container(
            // decoration: BoxDecoration(
            //   color: blurColor?.withOpacity(0.1) ??
            //       whiteColor().withOpacity(0.1),
            // ),
            color:
                blurColor?.withValues(alpha: opacity!) ??
                primaryColor().withValues(alpha: opacity!),

            child: child,
          ),
        ),
        BlurType.filtered => Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: intensity!,
                sigmaY: intensity!,
                tileMode: TileMode.mirror,
              ),
              child: Container(
                color:
                    blurColor?.withValues(alpha: 0.4) ??
                    primaryColor().withValues(alpha: 0.4),
                child: child,
              ),
            ),
            child,
          ],
        ),
        BlurType.opacity => Container(
          color:
              blurColor?.withValues(alpha: opacity!) ??
              primaryColor().withValues(alpha: opacity!),
          child: child,
        ),
        BlurType.gradient => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [blurColor ?? accentColor(), blurColor ?? accentColor()],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: child,
        ),
        null => child,
      },
    );
  }
}
