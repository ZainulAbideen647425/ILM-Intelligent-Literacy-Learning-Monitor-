import 'package:flutter/material.dart';

import '../../core/theme/tokens.g.dart';

/// Truck-art zigzag band. Design rule: patterns only frame screens and the
/// writing area; work surfaces stay plain white.
class TruckArtBand extends StatelessWidget {
  const TruckArtBand({super.key, this.height = 12});

  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _ZigzagPainter()),
        ),
      );
}

class _ZigzagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final toothWidth = size.height * 1.4;
    final top = size.height * 0.55;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, top),
      Paint()..color = IlmColors.aubergine,
    );
    final teeth = Paint()..color = IlmColors.marigold;
    final path = Path();
    for (var x = 0.0; x < size.width; x += toothWidth) {
      path
        ..moveTo(x, top)
        ..lineTo(x + toothWidth / 2, size.height)
        ..lineTo(x + toothWidth, top)
        ..close();
    }
    canvas.drawPath(path, teeth);
    // Thin stripe of alternating rose / peacock along the top edge.
    final stripeHeight = size.height * 0.18;
    var i = 0;
    for (var x = 0.0; x < size.width; x += toothWidth / 2, i++) {
      canvas.drawRect(
        Rect.fromLTWH(x, top - stripeHeight, toothWidth / 2, stripeHeight),
        Paint()..color = i.isEven ? IlmColors.rose : IlmColors.peacock,
      );
    }
  }

  @override
  bool shouldRepaint(_ZigzagPainter oldDelegate) => false;
}

/// Patterned frame around a plain white work area (e.g. the writing canvas).
class TruckArtFrame extends StatelessWidget {
  const TruckArtFrame({
    super.key,
    required this.child,
    this.borderWidth = 10,
  });

  final Widget child;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(IlmRadius.lg);
    return CustomPaint(
      painter: _StripedFramePainter(borderWidth),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: ClipRRect(
          borderRadius: radius,
          child: ColoredBox(color: IlmColors.white, child: child),
        ),
      ),
    );
  }
}

class _StripedFramePainter extends CustomPainter {
  _StripedFramePainter(this.width);

  final double width;

  static const List<Color> _stripes = [
    IlmColors.marigold,
    IlmColors.rose,
    IlmColors.peacock,
    IlmColors.aubergine,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(IlmRadius.lg + 6),
    );
    canvas.save();
    canvas.clipRRect(outer);
    // Diagonal stripes across the whole box; the white child covers the middle.
    final stripe = width * 0.9;
    final extent = size.width + size.height;
    var i = 0;
    for (var d = -size.height; d < extent; d += stripe, i++) {
      final path = Path()
        ..moveTo(d, 0)
        ..lineTo(d + stripe, 0)
        ..lineTo(d + stripe - size.height, size.height)
        ..lineTo(d - size.height, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = _stripes[i % _stripes.length]);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StripedFramePainter old) => old.width != width;
}
