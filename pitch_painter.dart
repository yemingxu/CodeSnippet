part of 'pitch_widget.dart';

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white;

    final goalSize = _calcPitchGoalSize(pitchSize: size);
    final goalAreaSize = _calcPitchGoalAreaSize(pitchSize: size);
    final centerCircleSize = _calcPitchCenterCircleSize(pitchSize: size);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 2.0), Offset(size.width, size.height / 2.0), paint);
    canvas.drawCircle(
      Offset(size.width / 2.0, size.height / 2.0),
      centerCircleSize.width / 2.0,
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalSize.width) / 2.0,
        0,
        goalSize.width,
        goalSize.height,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalAreaSize.width) / 2.0,
        0,
        goalAreaSize.width,
        goalAreaSize.height,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalSize.width) / 2.0,
        size.height - goalSize.height,
        goalSize.width,
        goalSize.height,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalAreaSize.width) / 2.0,
        size.height - goalAreaSize.height,
        goalAreaSize.width,
        goalAreaSize.height,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const double _kPitchPaddingLR = 20;
const double _kPitchFootballerNumberSize = 26;
const double kFootballerEventIconSize = 12;

/// 计算场地宽高
Size _calcPitchSize({required double width}) {
  final aspectRatio = 1 / kPitchAspectRatio;
  final height = width / aspectRatio;
  return Size(width, height);
}

/// 计算场地背景条纹高度
double _calcPitchBackgroundStripeHeight({required double pitchHeight}) {
  final ratio = 56 / 544.38;
  return pitchHeight * ratio;
}

/// 计算球门尺寸
Size _calcPitchGoalSize({required Size pitchSize}) {
  final aspectRatio = 92.13 / 28.5;
  final widthRatio = 92.13 / 335.0;
  final width = widthRatio * pitchSize.width;
  final height = width / aspectRatio;
  return Size(width, height);
}

/// 计算球门区域尺寸
Size _calcPitchGoalAreaSize({required Size pitchSize}) {
  final aspectRatio = 209.38 / 85.5;
  final widthRatio = 209.38 / 335.0;
  final width = widthRatio * pitchSize.width;
  final height = width / aspectRatio;
  return Size(width, height);
}

Size _calcPitchCenterCircleSize({required Size pitchSize}) {
  final ratio = 100.5 / 335.0;
  final wh = pitchSize.width * ratio;
  return Size(wh, wh);
}
