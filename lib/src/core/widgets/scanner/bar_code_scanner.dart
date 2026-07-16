import 'package:ecored_app/src/core/utils/utils_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarCodeScanner extends StatefulWidget {
  final ValueNotifier<String> qrCode;
  const BarCodeScanner({super.key, required this.qrCode});

  @override
  State<BarCodeScanner> createState() => _BarCodeScannerState();
}

class _BarCodeScannerState extends State<BarCodeScanner> {
  final MobileScannerController _controller = MobileScannerController();
  final ValueNotifier<bool> _isFlashEnabledNotifier = ValueNotifier(false);

  bool isScanned = false;

  void _handleBarcode(BarcodeCapture barcodes) {
    final String? rawValue = barcodes.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || isScanned) return;
    isScanned = true;

    if (mounted) {
      widget.qrCode.value = rawValue;
      Navigator.pop(context, rawValue);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _isFlashEnabledNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: UtilSize.width(context),
      height: UtilSize.height(context) * 0.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            MobileScanner(controller: _controller, onDetect: _handleBarcode),
            ValueListenableBuilder(
              valueListenable: _isFlashEnabledNotifier,
              builder: (context, bool isFlashEnabled, child) {
                return Positioned(
                  bottom: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      // Haptics.vibrate(HapticsType.soft);
                      _isFlashEnabledNotifier.value =
                          _isFlashEnabledNotifier.value == false;
                      _controller.toggleTorch();
                    },
                    child: AnimatedCrossFade(
                      firstChild: Icon(
                        CupertinoIcons.bolt_fill,
                        color: CupertinoColors.systemYellow,
                        size: 30,
                      ),
                      secondChild: Icon(
                        CupertinoIcons.bolt,
                        color: CupertinoColors.white,
                        size: 30,
                      ),
                      // firstChild: BlurIcon(
                      //   blurOpacity: 0.3,
                      //   icon: CupertinoIcons.bolt_fill,
                      //   iconColor: accentColor(),
                      // ),
                      // secondChild: BlurIcon(
                      //   blurOpacity: 0.2,
                      //   blurColor: whiteColor(),
                      //   icon: CupertinoIcons.bolt,
                      // ),
                      crossFadeState:
                          isFlashEnabled
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 200),
                    ),
                  ),
                );
              },
            ),
            //
          ],
        ),
      ),
    );
  }
}
