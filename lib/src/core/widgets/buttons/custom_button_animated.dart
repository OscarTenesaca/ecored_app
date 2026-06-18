import 'package:flutter/material.dart';

class CustomButtonAnimated extends StatelessWidget {
  final ValueNotifier<bool> isChargingNotifier;

  final String titleA;
  final String titleB;

  final Color backgroundColorA;
  final Color backgroundColorB;

  final Color textColorA;
  final Color textColorB;

  final Color borderColorA;
  final Color borderColorB;

  final Color shadowColorA;
  final Color shadowColorB;

  final VoidCallback? onPressed;

  const CustomButtonAnimated({
    super.key,
    required this.isChargingNotifier,

    required this.titleA,
    String? titleB,

    required this.backgroundColorA,
    Color? backgroundColorB,

    required this.textColorA,
    Color? textColorB,

    required this.borderColorA,
    Color? borderColorB,

    required this.shadowColorA,
    Color? shadowColorB,

    this.onPressed,
  }) : titleB = titleB ?? titleA,
       backgroundColorB = backgroundColorB ?? backgroundColorA,
       textColorB = textColorB ?? textColorA,
       borderColorB = borderColorB ?? borderColorA,
       shadowColorB = shadowColorB ?? shadowColorA;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isChargingNotifier,
      builder: (context, isCharging, child) {
        return SizedBox(
          width: double.infinity,
          height: 60,

          child: ElevatedButton(
            onPressed: onPressed,

            style: ElevatedButton.styleFrom(
              elevation: 0,

              backgroundColor: isCharging ? backgroundColorA : backgroundColorB,

              shadowColor: isCharging ? shadowColorA : shadowColorB,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              side: BorderSide(color: isCharging ? borderColorA : borderColorB),
            ),

            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),

              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },

              child: Text(
                isCharging ? titleA : titleB,

                key: ValueKey(isCharging),

                style: TextStyle(
                  color: isCharging ? textColorA : textColorB,

                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
// import 'package:flutter/material.dart';

// class CustomButtonAnimated extends StatelessWidget {
//   final ValueNotifier<bool> isChargingNotifier;

//   final String titleA;
//   final String titleB;

//   final Color backgroundColorA;
//   final Color backgroundColorB;

//   final Color textColorA;
//   final Color textColorB;

//   final Color borderColorA;
//   final Color borderColorB;

//   final Color shadowColorA;
//   final Color shadowColorB;

//   final VoidCallback? onPressed;

//   const CustomButtonAnimated({
//     super.key,
//     required this.isChargingNotifier,

//     required this.titleA,
//     required this.titleB,

//     required this.backgroundColorA,
//     required this.backgroundColorB,

//     required this.textColorA,
//     required this.textColorB,

//     required this.borderColorA,
//     required this.borderColorB,

//     required this.shadowColorA,
//     required this.shadowColorB,

//     this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<bool>(
//       valueListenable: isChargingNotifier,
//       builder: (context, isCharging, child) {
//         return SizedBox(
//           width: double.infinity,
//           height: 60,

//           child: ElevatedButton(
//             onPressed: onPressed,

//             style: ElevatedButton.styleFrom(
//               elevation: 0,

//               backgroundColor: isCharging ? backgroundColorA : backgroundColorB,

//               shadowColor: isCharging ? shadowColorA : shadowColorB,

//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),

//               side: BorderSide(color: isCharging ? borderColorA : borderColorB),
//             ),

//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),

//               transitionBuilder: (child, animation) {
//                 return FadeTransition(opacity: animation, child: child);
//               },

//               child: Text(
//                 isCharging ? titleA : titleB,

//                 key: ValueKey(isCharging),

//                 style: TextStyle(
//                   color: isCharging ? textColorA : textColorB,

//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
