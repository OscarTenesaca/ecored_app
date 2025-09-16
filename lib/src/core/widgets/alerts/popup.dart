import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:flutter/material.dart';

showPopUpWithChildren({
  required BuildContext context,
  required String title,
  required String subTitle,
  required String textButton,
  bool isPop = true,
  List<Widget>? children,
  Function? onSubmit,
  bool showButton = true,
}) {
  return showDialog(
    barrierDismissible: false,
    useSafeArea: false,
    context: context,
    builder: (contextBuilder) {
      return Material(
        color: Colors.transparent,
        child: Blur(
          intensity: Intensity.high.value,
          blurColor: whiteColor(),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.loose,
            children: [
              Positioned.fill(
                child: GestureDetector(onTap: () => Navigator.pop(context)),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Blur(
                    intensity: Intensity.megaHigh.value,
                    blurColor: primaryColor(),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 15,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'YaroRg',
                              fontSize: 14,
                              color: accentColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'YaroRg',
                              fontSize: 12,
                            ),
                          ),
                          Column(
                            spacing: 20,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: children ?? [],
                          ),
                          if (showButton)
                            CustomButton(
                              buttonColor: accentColor(),
                              textButtonColor: primaryColor(),
                              textButton: textButton,
                              onPressed: () {
                                onSubmit?.call();
                                if (isPop) Navigator.pop(context);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ? Show modal
showModalChild({required BuildContext context, required Widget child}) {
  return showDialog(
    barrierDismissible: false, // 👈 no se cierra al tocar afuera
    useSafeArea: false,
    context: context,
    builder: (contextBuilder) {
      return Material(
        color: Colors.transparent,
        child: Blur(
          intensity: Intensity.high.value,
          blurColor: whiteColor(),
          child: Stack(
            children: [
              // Contenido centrado
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: UtilSize.width(context) * 0.05,
                        vertical: 10,
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            radius: 16,
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    child,
                  ],
                ),
              ),

              // Botón de cerrar en la esquina superior derecha
              // Positioned(
              //   top: 20,
              //   right: 20,
              //   child: GestureDetector(
              //     onTap: () => Navigator.pop(context),
              //     child: Container(
              //       decoration: BoxDecoration(
              //         color: Colors.black54,
              //         shape: BoxShape.circle,
              //       ),
              //       padding: const EdgeInsets.all(8),
              //       child: const Icon(
              //         Icons.close,
              //         color: Colors.white,
              //         size: 20,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      );
    },
  );
}

// showModalChild({required BuildContext context, required Widget child}) {
//   return showDialog(
//     barrierDismissible: false,
//     useSafeArea: false,
//     context: context,
//     builder: (contextBuilder) {
//       return Material(
//         color: Colors.transparent,
//         child: Blur(
//           intensity: Intensity.high.value,
//           blurColor: whiteColor(),
//           child: Stack(
//             alignment: Alignment.center,
//             fit: StackFit.loose,
//             children: [
//               Positioned.fill(
//                 child: GestureDetector(onTap: () => Navigator.pop(context)),
//               ),

//               child,
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

// showModal({
//   required List<String> options,
//   required ValueNotifier<String> notifier,
//   required BuildContext context,
//   required Function onSelected,
//   required Function(int) onChanged,
//   required int initialItem,
// }) {
//   showCupertinoModalPopup(
//     context: context,
//     builder:
//         (context) => Blur(
//           intensity: Intensity.ultraHigh.value,
//           opacity: 0.4,
//           blurColor: Colors.black,
//           child: Container(
//             decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
//             height: 220,
//             padding: const EdgeInsets.only(top: 5),
//             margin: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom,
//             ),
//             child: SafeArea(
//               top: false,
//               child: Column(
//                 children: [
//                   Flexible(
//                     child: Center(
//                       child: CupertinoPicker(
//                         itemExtent: 40,
//                         scrollController: FixedExtentScrollController(
//                           initialItem: initialItem,
//                         ),
//                         onSelectedItemChanged: onChanged,
//                         children: List.generate(options.length, (index) {
//                           return Center(
//                             child: Text(
//                               options[index],
//                               style: TextStyle(
//                                 fontFamily: 'YaroRg',
//                                 fontSize: 16,
//                                 color: whiteColor(),
//                               ),
//                             ),
//                           );
//                         }),
//                       ),
//                     ),
//                   ),
//                   WidgetButton(
//                     textButton: 'Guardar',
//                     buttonColor: accentColor(),
//                     textButtonColor: primaryColor(),
//                     onPressed: () {
//                       onSelected();
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//   );
// }
