import 'package:flutter/material.dart';

BoxDecoration glass({bool deep = false}) {
  return BoxDecoration(
    color: Colors.white.withOpacity(deep ? 0.07 : 0.05),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.white.withOpacity(0.08)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        blurRadius: deep ? 16 : 12,
        spreadRadius: 0,
        offset: const Offset(0, 6),
      ),
    ],
    backgroundBlendMode: BlendMode.overlay,
  );
}
