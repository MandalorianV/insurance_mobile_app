import 'package:flutter/material.dart';

class AppShaderWarmUp extends ShaderWarmUp {
  const AppShaderWarmUp();

  @override
  Future<void> warmUpOnCanvas(Canvas canvas) async {
    // Uygulamandaki gradient + ClipRRect kombinasyonunu simüle et
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Color(0xFF6C63FF), Color(0xFF3B3486)],
      ).createShader(Rect.fromLTWH(0, 0, 400, 120));

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, 400, 120),
      const Radius.circular(20),
    );

    canvas.drawRRect(rrect, paint);
  }
}
