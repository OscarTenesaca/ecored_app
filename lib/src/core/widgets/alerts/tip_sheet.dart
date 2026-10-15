import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:flutter/material.dart';

/// Un consejo para [showTipSheet]. [category] y [summary] sirven además para
/// la tarjeta que lo abre (título corto y subtítulo).
class TipSheetItem {
  final String category;
  final String summary;
  final String title;
  final String description;
  final Widget icon;
  // Ilustración opcional entre el título y el texto (p. ej. [TipRangeBar]).
  final Widget? visual;

  const TipSheetItem({
    required this.category,
    required this.summary,
    required this.title,
    required this.description,
    required this.icon,
    this.visual,
  });
}

/// Hoja inferior con un consejo y navegación "Siguiente consejo" entre todos
/// los de [tips], empezando por [initialIndex].
Future<void> showTipSheet(
  BuildContext context, {
  required List<TipSheetItem> tips,
  int initialIndex = 0,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TipSheet(tips: tips, initialIndex: initialIndex),
  );
}

class _TipSheet extends StatefulWidget {
  final List<TipSheetItem> tips;
  final int initialIndex;

  const _TipSheet({required this.tips, required this.initialIndex});

  @override
  State<_TipSheet> createState() => _TipSheetState();
}

class _TipSheetState extends State<_TipSheet> {
  late int _index = widget.initialIndex.clamp(0, widget.tips.length - 1);

  bool get _hasNext => _index < widget.tips.length - 1;

  @override
  Widget build(BuildContext context) {
    final tip = widget.tips[_index];
    final media = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
      decoration: BoxDecoration(
        color: deepForestGreen(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      // Material propio para que los efectos de toque no queden tapados por
      // el fondo del Container.
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder:
                        (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                    child: _TipContent(
                      key: ValueKey(_index),
                      tip: tip,
                      position: _index + 1,
                      total: widget.tips.length,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: Material(
                      color: accentColor(),
                      shape: const StadiumBorder(),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: () => Navigator.pop(context),
                        child: Center(
                          child: Text(
                            'Entendido',
                            style: TextStyle(
                              color: primaryColor(),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_hasNext) ...[
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => setState(() => _index++),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Siguiente consejo',
                            style: TextStyle(
                              color: accentColor(),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: accentColor(),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TipContent extends StatelessWidget {
  final TipSheetItem tip;
  final int position;
  final int total;

  const _TipContent({
    super.key,
    required this.tip,
    required this.position,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor().withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconTheme(
                data: IconThemeData(color: accentColor(), size: 24),
                child: Center(child: tip.icon),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: accentColor(),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Consejo $position de $total',
                    style: TextStyle(color: grayInputColor(), fontSize: 13),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.white.withValues(alpha: 0.08),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.pop(context),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.close, color: whiteColor()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          tip.title,
          style: TextStyle(
            color: whiteColor(),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
        ),
        if (tip.visual != null) ...[const SizedBox(height: 22), tip.visual!],
        const SizedBox(height: 20),
        Text(
          tip.description,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 15,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

/// Barra con un rango resaltado, p. ej. la zona de carga recomendada
/// (20%–80%). Muestra las marcas de los extremos y del rango.
class TipRangeBar extends StatelessWidget {
  final double start;
  final double end;
  final double min;
  final double max;
  final String? label;
  final String unit;

  const TipRangeBar({
    super.key,
    required this.start,
    required this.end,
    this.min = 0,
    this.max = 100,
    this.label,
    this.unit = '%',
  });

  String _format(double value) =>
      '${value == value.roundToDouble() ? value.toInt() : value}$unit';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double x(double value) =>
            ((value - min) / (max - min)).clamp(0.0, 1.0) * width;

        final left = x(start);
        final right = x(end);
        const markWidth = 48.0;

        Widget mark(double value, {required bool strong}) {
          final center = x(value);
          return Positioned(
            left: (center - markWidth / 2).clamp(0.0, width - markWidth),
            width: markWidth,
            child: Text(
              _format(value),
              textAlign:
                  value <= min
                      ? TextAlign.left
                      : value >= max
                      ? TextAlign.right
                      : TextAlign.center,
              style: TextStyle(
                color: strong ? whiteColor() : grayInputColor(),
                fontSize: 12,
                fontWeight: strong ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (label != null)
              Padding(
                padding: EdgeInsets.only(left: left),
                child: SizedBox(
                  width: right - left,
                  child: Text(
                    label!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: TextStyle(
                      color: accentColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (label != null) const SizedBox(height: 6),
            SizedBox(
              height: 16,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Positioned(
                    left: left,
                    width: right - left,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: accentColor(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 16,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (start > min) mark(min, strong: false),
                  mark(start, strong: true),
                  mark(end, strong: true),
                  if (end < max) mark(max, strong: false),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
