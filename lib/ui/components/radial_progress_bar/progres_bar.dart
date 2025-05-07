import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RadialPercentWidget extends StatelessWidget {
  final Widget child;
  final double percent;
  final Color fillColor;
  final Color freeColor;
  final double lineWidth;

  const RadialPercentWidget({
    super.key,
    required this.child,
    required this.percent,
    required this.fillColor,
    required this.freeColor,
    required this.lineWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: percent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (context, animatedPercent, childInside) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: MyPainter(
                  percent: animatedPercent,
                  fillColor: fillColor,
                  freeColor: freeColor,
                  lineWidth: lineWidth,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(11.0),
                child: Center(child: childInside),
              ),
            ],
          );
        },
        child: child, // <-- чтобы текст не пересоздавался каждую миллисекунду
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final Color fillColor;
  final Color freeColor;
  final double lineWidth;
  final double percent;

  MyPainter({
    required this.percent,
    required this.fillColor,
    required this.freeColor,
    required this.lineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final arcRect = calculateArcRects(size);

    drawBackGround(canvas, size);
    drawFreeArc(canvas, arcRect);
    drawFillArc(canvas, arcRect);
  }

  void drawFillArc(Canvas canvas, Rect arcRect) {
    final paint = Paint();
    paint.color = _calculateLineColor(); // <--- тут теперь меняем цвет
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = lineWidth;
    paint.strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, -pi / 2, pi * 2 * percent, false, paint);
  }

  void drawFreeArc(Canvas canvas, Rect arcRect) {
    final paint = Paint();
    paint.color = freeColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = lineWidth;
    paint.strokeCap = StrokeCap.round;

    canvas.drawArc(
      arcRect,
      pi * 2 * percent - (pi / 2),
      pi * 2 * (1.0 - percent),
      false,
      paint,
    );
  }

  void drawBackGround(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = fillColor;
    paint.style = PaintingStyle.fill;
    canvas.drawOval(Offset.zero & size, paint);
  }

  Rect calculateArcRects(Size size) {
    final lineMargin = 5;
    final offset = lineWidth / 2 + lineMargin;
    return Offset(offset, offset) &
        Size(size.width - offset * 2, size.height - offset * 2);
  }

  Color _calculateLineColor() {
    // Плавный переход от жёлтого (255, 255, 0) к светло-зелёному (76, 175, 80)
    final red = (255 * (1 - percent) + 76 * percent).toInt();
    final green = (255 * (1 - percent) + 175 * percent).toInt();
    final blue = (0 * (1 - percent) + 80 * percent).toInt();

    return Color.fromARGB(255, red, green, blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
