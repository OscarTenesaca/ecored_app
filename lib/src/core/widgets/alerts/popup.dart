import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:flutter/material.dart';

// information popup with custom children and one button
showPopUpWithChildren({
  required BuildContext context,
  required String title,
  required String subTitle,
  required String textButton,
  String? textButtonClose,
  bool isPop = true,
  List<Widget>? children,
  Function? onSubmit,
  Function? onClose,
  bool showButton = true,
  double sizeTitle = 16,
  double sizeSubtitle = 14,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    useSafeArea: false,
    builder: (_) {
      return Material(
        color: Colors.transparent,
        child: Blur(
          intensity: Intensity.high.value,
          blurColor: Colors.black.withValues(alpha: .25),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Blur(
                intensity: Intensity.megaHigh.value,
                blurColor: Colors.black.withValues(alpha: .45),
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111714).withValues(alpha: .85),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .08),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sizeTitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        subTitle,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: sizeSubtitle,
                          height: 1.5,
                        ),
                      ),

                      if (children != null && children.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      ],

                      if (showButton || textButtonClose != null) ...[
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            if (textButtonClose != null)
                              TextButton(
                                onPressed: () {
                                  onClose?.call();
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  textButtonClose,
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: sizeSubtitle,
                                  ),
                                ),
                              ),

                            const Spacer(),

                            if (showButton)
                              TextButton(
                                onPressed: () {
                                  onSubmit?.call();
                                  if (isPop) Navigator.pop(context);
                                },
                                child: Text(
                                  textButton,
                                  style: TextStyle(
                                    color: accentColor(),
                                    fontSize: sizeSubtitle,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
// showPopUpWithChildren({
//   required BuildContext context,
//   required String title,
//   required String subTitle,
//   required String textButton,
//   String? textButtonClose,
//   bool isPop = true,
//   List<Widget>? children,
//   Function? onSubmit,
//   Function? onClose,
//   bool showButton = true,
// }) {
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
//               // Fondo tocable para cerrar el pop-up
//               Positioned.fill(
//                 child: GestureDetector(onTap: () => Navigator.pop(context)),
//               ),
//               // Pop-up central
//               Center(
//                 child: Container(
//                   margin: const EdgeInsets.all(20),
//                   child: Blur(
//                     intensity: Intensity.megaHigh.value,
//                     blurColor: primaryColor(),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         spacing: 15,
//                         children: [
//                           // Título
//                           Text(
//                             title,
//                             style: TextStyle(
//                               fontFamily: 'YaroRg',
//                               fontSize: 14,
//                               color: accentColor(),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           // Subtítulo
//                           Text(
//                             subTitle,
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                               fontFamily: 'YaroRg',
//                               fontSize: 12,
//                               height: 1.5,
//                             ),
//                           ),
//                           // Widgets extra (children)
//                           if (children != null && children.isNotEmpty)
//                             Column(
//                               spacing: 20,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: children,
//                             ),
//                           // Botones
//                           if (showButton || textButtonClose != null)
//                             Row(
//                               children: [
//                                 if (textButtonClose != null)
//                                   TextButton(
//                                     onPressed: () {
//                                       onClose?.call();
//                                       Navigator.pop(context);
//                                     },
//                                     child: Text(
//                                       textButtonClose,
//                                       style: TextStyle(
//                                         color: grayInputColor(),
//                                         // fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),

//                                 const Spacer(),
//                                 if (showButton)
//                                   TextButton(
//                                     onPressed: () {
//                                       onSubmit?.call();
//                                       if (isPop) Navigator.pop(context);
//                                     },
//                                     child: Text(
//                                       textButton,
//                                       style: TextStyle(
//                                         color: accentColor(),
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

// showPopUpWithChildren({
//   required BuildContext context,
//   required String title,
//   required String subTitle,
//   required String textButton,
//   String? textButtonClose,
//   bool isPop = true,
//   List<Widget>? children,
//   Function? onSubmit,
//   Function? onClose,
//   bool showButton = true,
// }) {
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
//               Center(
//                 child: Container(
//                   margin: const EdgeInsets.all(20),
//                   child: Blur(
//                     intensity: Intensity.megaHigh.value,
//                     blurColor: primaryColor(),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         spacing: 15,
//                         children: [
//                           Text(
//                             title,
//                             style: TextStyle(
//                               fontFamily: 'YaroRg',
//                               fontSize: 14,
//                               color: accentColor(),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             subTitle,
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                               fontFamily: 'YaroRg',
//                               fontSize: 12,
//                             ),
//                           ),
//                           Column(
//                             spacing: 20,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: children ?? [],
//                           ),
//                           if (showButton)
//                             CustomButton(
//                               buttonColor: accentColor(),
//                               textButtonColor: primaryColor(),
//                               textButton: textButton,
//                               onPressed: () {
//                                 onSubmit?.call();
//                                 if (isPop) Navigator.pop(context);
//                               },
//                             ),

//                           // Close button
//                           if (textButtonClose != null)
//                             TextButton(
//                               onPressed: () {
//                                 onClose?.call();
//                                 Navigator.pop(context);
//                               },
//                               child: Text(
//                                 textButtonClose,
//                                 style: TextStyle(
//                                   color: accentColor(),
//                                   fontFamily: 'YaroRg',
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

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

class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool primary;

  const DialogButton({
    super.key,
    required this.text,
    this.onPressed,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(110, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: primary ? accentColor() : Colors.transparent,
        foregroundColor: primary ? primaryColor() : accentColor(),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
