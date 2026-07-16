import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAssetSvg extends StatelessWidget {
  final double width;
  final double height;
  final String imagePath;
  final BoxFit boxFit;

  const CustomAssetSvg({
    super.key,
    this.width = 0,
    this.height = 0,
    this.imagePath = AssetPaths.logo_text,
    this.boxFit = BoxFit.fill,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = UtilSize.width(context);

    final double widthSize = (width == 0) ? screenWidth * 35 / 100 : width;
    final double heightSize = (height == 0) ? screenWidth * 35 / 100 : height;

    return SizedBox(
      width: widthSize,
      height: heightSize,
      child: SvgPicture.asset(imagePath, fit: boxFit),
    );
  }
}
