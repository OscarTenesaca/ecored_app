import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:flutter/material.dart';

class CustomAssetImg extends StatelessWidget {
  final double width;
  final double height;
  final String imagePath;
  final BoxFit boxFit;

  const CustomAssetImg({
    Key? key,
    this.width = 0,
    this.height = 0,
    this.imagePath = AssetPaths.logo_text,
    this.boxFit = BoxFit.fill,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = UtilSize.width(context);

    final double widthSize = (width == 0) ? screenWidth * 35 / 100 : width;
    final double heightSize = (height == 0) ? screenWidth * 35 / 100 : height;

    return SizedBox(
      width: widthSize,
      height: heightSize,
      child: Image.asset(imagePath, fit: boxFit),
    );
  }
}
