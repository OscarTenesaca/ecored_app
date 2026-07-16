import 'package:flutter/material.dart';

BoxDecoration glass({bool deep = false}) {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: deep ? 0.07 : 0.05),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: deep ? 16 : 12,
        spreadRadius: 0,
        offset: const Offset(0, 6),
      ),
    ],
    backgroundBlendMode: BlendMode.overlay,
  );
}

// ================= HELPERS =================
BoxDecoration cardDecoration({bool shadow = false}) {
  return BoxDecoration(
    color: Color(0xff111111),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0xff2A2A2A)),
    boxShadow:
        shadow
            ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ]
            : null,
  );
}
