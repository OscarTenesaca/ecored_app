import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBottomButton extends StatefulWidget {
  final ValueNotifier<int> indexNotifier;
  final IconData icon;
  final bool isSelected;
  final int index;
  final String? label;

  const CustomBottomButton({
    super.key,
    required this.indexNotifier,
    required this.icon,
    required this.isSelected,
    required this.index,
    this.label,
  });

  @override
  State<CustomBottomButton> createState() => _CustomBottomButtonState();
}

class _CustomBottomButtonState extends State<CustomBottomButton> {
  @override
  Widget build(BuildContext context) {
    return ScaleEffect(
      child: Blur(
        type: widget.isSelected ? BlurType.gradient : BlurType.opacity,
        blurColor:
            widget.isSelected ? accentColor() : greyColorWithTransparency(),
        child: Row(
          children: [
            IconButton(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(
                widget.icon,
                size: 25,
                color: widget.isSelected ? primaryColor() : Colors.grey[400],
              ),
              onPressed: () {
                widget.indexNotifier.value = widget.index;
              },
              color: primaryColor(),
            ),
            if (widget.label != null && widget.isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  widget.label!,
                  style: TextStyle(
                    color:
                        widget.isSelected ? primaryColor() : Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// import 'package:ecored_app/src/core/theme/theme_index.dart';
// import 'package:ecored_app/src/core/widgets/widget_index.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class CustomBottomButton extends StatefulWidget {
//   final ValueNotifier<int> indexNotifier;
//   final IconData icon;
//   final bool isSelected;
//   final int index;
//   final String? label;

//   const CustomBottomButton({
//     super.key,
//     required this.indexNotifier,
//     required this.icon,
//     required this.isSelected,
//     required this.index,
//     this.label,
//   });

//   @override
//   State<CustomBottomButton> createState() => _CustomBottomButtonState();
// }

// class _CustomBottomButtonState extends State<CustomBottomButton>
//     with TickerProviderStateMixin {
//   @override
//   Widget build(BuildContext context) {
//     return IntrinsicWidth(
//       child: ScaleEffect(
//         child: Blur(
//           type: widget.isSelected ? BlurType.gradient : BlurType.opacity,
//           blurColor:
//               widget.isSelected ? accentColor() : greyColorWithTransparency(),
//           child: AnimatedSize(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             alignment: Alignment.centerLeft,
//             child: Row(
//               mainAxisSize:
//                   MainAxisSize.min, // Evita que se expanda innecesariamente
//               children: [
//                 IconButton(
//                   focusColor: Colors.transparent,
//                   hoverColor: Colors.transparent,
//                   splashColor: Colors.transparent,
//                   highlightColor: Colors.transparent,
//                   icon: Icon(
//                     widget.icon,
//                     size: 25,
//                     color: widget.isSelected ? primaryColor() : Colors.grey[400],
//                   ),
//                   onPressed: () {
//                     widget.indexNotifier.value = widget.index;
//                   },
//                 ),
//                 if (widget.label != null)
//                   AnimatedSwitcher(
//                     duration: const Duration(milliseconds: 300),
//                     switchInCurve: Curves.easeIn,
//                     switchOutCurve: Curves.easeOut,
//                     transitionBuilder:
//                         (child, animation) => FadeTransition(
//                           opacity: animation,
//                           child: SizeTransition(
//                             sizeFactor: animation,
//                             axis: Axis.horizontal,
//                             child: child,
//                           ),
//                         ),
//                     child:
//                         widget.isSelected
//                             ? Padding(
//                               key: const ValueKey('label'),
//                               padding: const EdgeInsets.only(right: 8.0),
//                               child: Text(
//                                 widget.label!,
//                                 style: TextStyle(
//                                   color: primaryColor(),
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             )
//                             : const SizedBox(key: ValueKey('empty')),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
