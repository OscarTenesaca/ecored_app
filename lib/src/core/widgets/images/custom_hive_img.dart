import 'dart:convert';
import 'dart:math';

import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:flutter/material.dart';

class CustomHiveImg extends StatelessWidget {
  final String img;
  final String title;
  final double size;
  final AlignmentGeometry alignment;
  final Color? color;
  final Function()? onTap;

  const CustomHiveImg({
    Key? key,
    required this.img,
    this.title = '',
    this.size = 90,
    this.alignment = Alignment.bottomRight,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(15),
            width: size,
            height: size,
            child: Stack(
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: Arc(
                      alreadyWatch: 0,
                      numberOfArc: 1,
                      spacing: 10,
                      strokeWidth: 4,
                      seenColor: Colors.grey,
                      unSeenColor: color ?? grayInputColor(),
                    ),
                  ),
                ),
                (img.contains('files/user/'))
                    ? Container(
                      margin: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        // backgroundColor: Colors.grey,
                        backgroundColor: greyColorWithTransparency(),
                        radius: size,
                        // backgroundImage: NetworkImage(img),
                        // child: ShimmerLoading(),
                        child: FutureBuilder(
                          future: precacheImage(NetworkImage(img), context),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return CircleAvatar(
                                backgroundColor: primaryColor(),
                                radius: size,
                                backgroundImage: NetworkImage(img),
                              );
                            } else {
                              // return ShimmerLoading(
                              //   enabled: true,
                              //   borderRadius: BorderRadius.circular(100),
                              //   child: const SizedBox(),
                              // );
                              return Text("loadding...");
                            }
                          },
                        ),
                      ),
                    )
                    : Container(
                      margin: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: size,
                        backgroundImage: MemoryImage(base64.decode(img)),
                      ),
                    ),
              ],
            ),
          ),
          Visibility(
            visible: title.isNotEmpty,
            child: LabelTitle(title: title, alignment: Alignment.center),
          ),
        ],
      ),
    );
  }
}

class Arc extends CustomPainter {
  final int numberOfArc;
  final int alreadyWatch;
  final double spacing;
  final double strokeWidth;
  final Color seenColor;
  final Color unSeenColor;
  Arc({
    required this.numberOfArc,
    required this.alreadyWatch,
    required this.spacing,
    required this.strokeWidth,
    required this.seenColor,
    required this.unSeenColor,
  });

  double doubleToAngle(double angle) => angle * pi / 180.0;

  void drawArcWithRadius(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    Paint seenPaint,
    Paint unSeenPaint,
    double start,
    double spacing,
    int number,
    int alreadyWatch,
  ) {
    for (var i = 0; i < number; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        doubleToAngle((start + ((angle + spacing) * i))),
        doubleToAngle(angle),
        false,
        alreadyWatch - 1 >= i ? seenPaint : unSeenPaint,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2.0, size.height / 2.0);
    final double radius = size.width / 2.0;
    double angle =
        numberOfArc == 1 ? 240.0 : (360.0 / numberOfArc - spacing); //change
    var startingAngle = 330.0;

    Paint seenPaint =
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..color = seenColor;

    Paint unSeenPaint =
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..color = unSeenColor;

    drawArcWithRadius(
      canvas,
      center,
      radius,
      angle,
      seenPaint,
      unSeenPaint,
      startingAngle,
      spacing,
      numberOfArc,
      alreadyWatch,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
