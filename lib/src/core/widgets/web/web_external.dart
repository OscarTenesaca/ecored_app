import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebExternal extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final String url;

  const WebExternal({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 0,

    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final uriParse =
        Uri.parse(
          url,
          // "https://www.google.com/maps/dir/?api=1&origin=$latUser,$lngUser&destination=$latDest,$lngDest&travelmode=driving",
        ).toString();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(uriParse)),
        ),
      ),
    );
  }
}
