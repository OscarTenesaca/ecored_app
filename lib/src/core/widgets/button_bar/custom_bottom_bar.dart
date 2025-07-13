import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/widgets/button_bar/custom_bottom_button_bar.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:flutter/cupertino.dart';

class CustomBottonBar extends StatefulWidget {
  final ValueNotifier<int> indexNotifier;

  const CustomBottonBar({super.key, required this.indexNotifier});

  @override
  State<CustomBottonBar> createState() => _CustomBottonBarState();
}

class _CustomBottonBarState extends State<CustomBottonBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Blur(
        opacity: 0.5,
        borderRadius: BorderRadius.circular(25),
        blurColor: primaryColor(),
        intensity: Intensity.high.value,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
          child: ValueListenableBuilder(
            valueListenable: widget.indexNotifier,
            builder: (context, index, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomBottomButton(
                    indexNotifier: widget.indexNotifier,
                    icon: CupertinoIcons.house,
                    index: 0,
                    isSelected: index == 0,
                    label: 'Inicio',
                  ),
                  CustomBottomButton(
                    indexNotifier: widget.indexNotifier,
                    icon: CupertinoIcons.map,
                    index: 1,
                    isSelected: index == 1,
                    label: 'Estaciones',
                  ),
                  CustomBottomButton(
                    indexNotifier: widget.indexNotifier,
                    icon: CupertinoIcons.money_dollar,
                    index: 2,
                    isSelected: index == 2,
                    label: 'Finanzas',
                  ),
                  CustomBottomButton(
                    indexNotifier: widget.indexNotifier,
                    icon: CupertinoIcons.person,
                    index: 3,
                    isSelected: index == 3,
                    label: 'Perfil',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
