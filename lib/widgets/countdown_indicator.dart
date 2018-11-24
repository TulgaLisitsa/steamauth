import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CountdownIndicator extends StatefulWidget {
  const CountdownIndicator({Key key, this.size, this.progress, this.valueColor})
      : super(key: key);

  final Size size;
  final Function progress;

  /// Defaults to [ThemeData.primaryColor].
  final Color valueColor;

  Color _getValueColor(BuildContext context) =>
      valueColor?.value ?? Theme.of(context).primaryColor;

  @override
  _IndicatorState createState() => new _IndicatorState();
}

class _IndicatorState extends State<CountdownIndicator>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      size: (widget.size == null) ? new Size(16.0, 16.0) : widget.size,
      painter: _ProgressPainter(
          widget.progress() as double,
          (widget.valueColor == null)
              ? widget._getValueColor(context)
              : widget.valueColor),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  double value;
  Color valueColor;

  Timer timer;

  @override
  paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;

    canvas.drawArc(rect, -pi / 2, -2 * pi * (1 - this.value), true,
        new Paint()..color = valueColor);
  }

  @override
  bool shouldRepaint(_ProgressPainter oldDelegate) {
    return oldDelegate.value != this.value ||
        oldDelegate.valueColor != this.valueColor;
  }

  _ProgressPainter(this.value, this.valueColor);
}
