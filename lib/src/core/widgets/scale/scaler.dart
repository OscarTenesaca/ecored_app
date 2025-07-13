import 'package:flutter/material.dart';

/// A widget that scales its child when it is pressed.
class ScaleEffect extends StatefulWidget {
  final Widget child;

  /// Creates a widget that scales its child when it is pressed.
  /// The [child] argument must not be null.
  /// The [key] argument is used to control the widget from the parent.
  const ScaleEffect({super.key, required this.child});

  @override
  State<ScaleEffect> createState() => _ScaleEffectState();
}

class _ScaleEffectState extends State<ScaleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.4).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) => _controller.forward(),
      onPanCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _animation,
        child: widget.child,
      ),
    );
  }
}
