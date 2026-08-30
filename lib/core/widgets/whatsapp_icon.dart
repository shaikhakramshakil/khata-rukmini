import 'package:flutter/material.dart';

class WhatsAppIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const WhatsAppIcon({super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WhatsAppPainter(color: color ?? const Color(0xFF25D366)),
    );
  }
}

class _WhatsAppPainter extends CustomPainter {
  final Color color;

  _WhatsAppPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Draw background circle / speech bubble
    final bgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.46;

    // Speech bubble path with subtle tail
    path.addOval(Rect.fromCircle(center: center, radius: radius));

    // Tail at bottom left
    final tailPath = Path();
    tailPath.moveTo(w * 0.28, h * 0.72);
    tailPath.lineTo(w * 0.12, h * 0.88);
    tailPath.lineTo(w * 0.22, h * 0.62);
    tailPath.close();

    canvas.drawPath(path, bgPaint);
    canvas.drawPath(tailPath, bgPaint);

    // Inner Phone handset in white
    final phonePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Scale and draw telephone handset icon
    final phonePath = Path();
    // Handset curved shape
    phonePath.moveTo(w * 0.35, h * 0.38);
    phonePath.cubicTo(
      w * 0.34,
      h * 0.36,
      w * 0.38,
      h * 0.32,
      w * 0.42,
      h * 0.32,
    );
    phonePath.cubicTo(
      w * 0.45,
      h * 0.32,
      w * 0.48,
      h * 0.36,
      w * 0.50,
      h * 0.40,
    );
    phonePath.cubicTo(
      w * 0.52,
      h * 0.43,
      w * 0.49,
      h * 0.46,
      w * 0.47,
      h * 0.48,
    );
    phonePath.cubicTo(
      w * 0.46,
      h * 0.50,
      w * 0.48,
      h * 0.54,
      w * 0.52,
      h * 0.58,
    );
    phonePath.cubicTo(
      w * 0.56,
      h * 0.62,
      w * 0.60,
      h * 0.64,
      w * 0.62,
      h * 0.63,
    );
    phonePath.cubicTo(
      w * 0.64,
      h * 0.61,
      w * 0.67,
      h * 0.58,
      w * 0.70,
      h * 0.60,
    );
    phonePath.cubicTo(
      w * 0.74,
      h * 0.62,
      w * 0.78,
      h * 0.65,
      w * 0.78,
      h * 0.68,
    );
    phonePath.cubicTo(
      w * 0.78,
      h * 0.72,
      w * 0.74,
      h * 0.76,
      w * 0.72,
      h * 0.75,
    );
    phonePath.cubicTo(
      w * 0.66,
      h * 0.76,
      w * 0.56,
      h * 0.70,
      w * 0.46,
      h * 0.60,
    );
    phonePath.cubicTo(
      w * 0.38,
      h * 0.52,
      w * 0.33,
      h * 0.44,
      w * 0.35,
      h * 0.38,
    );
    phonePath.close();

    canvas.drawPath(phonePath, phonePaint);
  }

  @override
  bool shouldRepaint(covariant _WhatsAppPainter oldDelegate) =>
      oldDelegate.color != color;
}
