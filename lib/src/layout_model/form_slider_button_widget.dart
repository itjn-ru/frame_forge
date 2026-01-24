import 'package:flutter/material.dart';

import '../canvas/layout_model_provider.dart';
import 'component.dart';
import 'component_widget.dart';
import 'controller/layout_model_controller.dart';
import 'layout_model.dart';
import 'style_element.dart';

class FormSliderButtonWidget extends ComponentWidget {
  final double scaleFactor;
  const FormSliderButtonWidget({
    required super.component,
    required this.scaleFactor,
    super.key,
  });

  @override
  Widget buildWidget(BuildContext context) {
    return CustomSlider(
      component: component,
      scale: scaleFactor,
    );
  }
}

class CustomSlider extends StatefulWidget {
  final LayoutComponent component;
  final double scale;
  const CustomSlider({
    super.key,
    required this.component,
    required this.scale,
  });

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double _currentSliderValue = 1;
  late final List<String> hintText;
  int initalValue = 0;
  late var style;
  final Color goodColor = const Color(0xFF21AB28);
  final Color badColor = const Color(0xFFF54947);
  List<Color> activeColors = <Color>[];

  @override
  void initState() {
    super.initState();
    initial();
  }

  @override
  void didUpdateWidget(covariant CustomSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.component['style'] != oldWidget.component['style'] ||
        widget.component['source'] != oldWidget.component['source'] ||
        widget.component['initialValue'] !=
            oldWidget.component['initialValue'] ||
        widget.component['hintText'] != oldWidget.component['hintText'] ||
        widget.component['activeColors'] !=
            oldWidget.component['activeColors']) {
      setState(initial);
    }
  }

  initial() {
    initalValue = _readInitialValue();
    final List<String> ht = _readHintText();
    activeColors = _readActiveColors();
    if (ht.isNotEmpty) {
      hintText = ht;
      // Clamp to available labels length (min 1 → last index 0)
      final int maxIndex = (hintText.length - 1).clamp(0, 1000);
      _currentSliderValue = initalValue.clamp(0, maxIndex).toDouble();
    } else {
      hintText = const <String>[' Недоступно', ' В наличии', ' Заканчивается'];
      _currentSliderValue = initalValue.clamp(0, 2).toDouble();
    }
  }

  int _readInitialValue() {
    final dynamic raw = widget.component['initialValue'];
    if (raw == null) return 0;
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }

  List<String> _readHintText() {
    final dynamic raw = widget.component['hintText'];
    if (raw == null) return const <String>[];
    if (raw is List<String>) return List<String>.from(raw);
    if (raw is List) {
      return raw
          .map((e) => e?.toString() ?? '')
          .where((String s) => s.isNotEmpty)
          .toList();
    }
    if (raw is String) {
      // Optional: support comma-separated string
      final List<String> parts = raw
          .split(',')
          .map((String e) => e.trim())
          .where((String s) => s.isNotEmpty)
          .toList();
      return parts;
    }
    return const <String>[];
  }

  List<Color> _readActiveColors() {
    final dynamic raw = widget.component['activeColors'];
    if (raw is List<Color>) {
      // Already a list of Color objects
      return List<Color>.from(raw);
    }
    if (raw is List) {
      // Legacy formats: int, string, mixed
      return raw
          .map<Color?>((dynamic e) => _parseColor(e))
          .whereType<Color>()
          .toList();
    }
    if (raw is String) {
      // Comma-separated hex strings
      return raw
          .split(',')
          .map((String s) => _parseColor(s))
          .whereType<Color>()
          .toList();
    }
    return const <Color>[];
  }

  Color? _parseColor(dynamic v) {
    if (v is Color) return v; // New direct Color support
    if (v is int) {
      return Color(v);
    }
    if (v is String) {
      String s = v.trim();
      if (s.startsWith('#')) s = s.substring(1);
      if (s.startsWith('0x')) s = s.substring(2);
      if (s.length == 6) s = 'FF$s'; // add full alpha if missing
      final int? val = int.tryParse(s, radix: 16);
      if (val != null) return Color(val);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final LayoutModelController controller =
        LayoutModelControllerProvider.of(context);
    final LayoutModel layoutModel = controller.layoutModel;
    final StyleElement style =
        layoutModel.getStyleElementById(widget.component['style'].id) ??
            StyleElement('style');

    final double fontSize = Theme.of(context).textTheme.titleSmall?.fontSize ??
        style['fontSize'].toDouble();
    final int steps = hintText.length;
    final int divisions = steps > 1 ? steps - 1 : 0;
    final double maxValue = steps > 1 ? (steps - 1).toDouble() : 0.0;
    final double clampedValue = _currentSliderValue.clamp(0.0, maxValue);
    final int idx = clampedValue.round();
    final TextStyle textStyle = TextStyle(
      color: style['color'],
      fontSize: style['fontSize'] * widget.scale,
      fontWeight: style['fontWeight'],
    );

    // Use provided color for the selected index or fallback to theme primary
    final Color selectedColor = (idx >= 0 && idx < activeColors.length)
        ? activeColors[idx]
        : Theme.of(context).colorScheme.primary;
    final Color inactiveColor =
        _parseColor(widget.component['inactiveColor']) ??
            Theme.of(context).disabledColor;
    final Color thumbColor =
        _parseColor(widget.component['thumbColor']) ?? Colors.white;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double w = constraints.maxWidth;
            final double trackUsable =
                w; // full width (adjust if padding needed)
            final int count = steps;
            if (count == 0) {
              return const SizedBox.shrink();
            }
            final double spacing =
                count > 1 ? trackUsable / (count - 1) : trackUsable;
            const double edgeFactor =
                0.55; // portion of spacing allowed for edge labels
            const double innerFactor =
                0.8; // portion of spacing allowed for inner labels
            const double minWidth =
                28; // ensure some minimal tap/visibility area
            const double horizontalPad = 4;

            List<_LabelMetrics> metrics = <_LabelMetrics>[];
            for (int i = 0; i < count; i++) {
              final TextPainter tp = TextPainter(
                text: TextSpan(text: hintText[i], style: textStyle),
                textDirection: TextDirection.ltr,
                maxLines: 1,
                ellipsis: '…',
              )..layout(maxWidth: trackUsable);
              double desired = tp.size.width + horizontalPad * 2;
              final double maxAllowed = (i == 0 || i == count - 1)
                  ? spacing * edgeFactor
                  : spacing * innerFactor;
              final double finalWidth = desired.clamp(minWidth, maxAllowed);
              metrics.add(_LabelMetrics(width: finalWidth, painter: tp));
            }
// Selected label full width (unclamped) for better UX visibility
            final int selectedIndex = idx.clamp(0, count - 1);
            final TextPainter selectedPainter = TextPainter(
              text: TextSpan(
                text: hintText[selectedIndex],
                style: textStyle.copyWith(
                    fontWeight: FontWeight.bold, color: selectedColor),
              ),
              textDirection: TextDirection.ltr,
              maxLines: 2, // allow wrap if needed
              ellipsis: '…',
            )..layout(maxWidth: trackUsable * 0.85); // keep some side margin
            final double selectedFraction =
                count <= 1 ? 0 : selectedIndex / (count - 1);
            final double selectedCenterX = selectedFraction * trackUsable;
            final double selectedWidth =
                selectedPainter.size.width + horizontalPad * 2;
            double selectedLeft = selectedCenterX - selectedWidth / 2;
            if (selectedLeft < 0) selectedLeft = 0;
            if (selectedLeft + selectedWidth > trackUsable) {
              selectedLeft = trackUsable - selectedWidth;
            }
            return SizedBox(
              height: (fontSize * 2.6).clamp(32, 72),
              child: Stack(children: <Widget>[
                // Truncated baseline labels (non-selected)
                for (int i = 0; i < count; i++)
                  if (i != selectedIndex)
                    (() {
                      final double fraction = count <= 1 ? 0 : i / (count - 1);
                      final double centerX = fraction * trackUsable;
                      final double width = metrics[i].width;
                      double left = centerX - width / 2;
                      if (left < 0) left = 0;
                      if (left + width > trackUsable)
                        left = trackUsable - width;
                      return Positioned(
                        left: left,
                        top: 0,
                        width: width,
                        child: Center(
                          child: Text(
                            hintText[i],
                            style: textStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    })(),
                // Selected label overlay (full, bold, highlighted)
                Positioned(
                  left: selectedLeft,
                  top: 0, // slight downward to separate layers
                  width: selectedWidth,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPad,
                      vertical: fontSize * 0.1,
                    ),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        hintText[selectedIndex],
                        style: textStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: selectedColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ]),
            );
          },
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            tickMarkShape: const SliderTickMarkCircle(),
            trackShape: const LineSliderTrackShape(),
            trackHeight: 1,
            thumbShape: SliderThumbShape(thumbColor: thumbColor),
            // Only thumb uses selectedColor; track & ticks use inactiveColor
            activeTrackColor: inactiveColor,
            disabledActiveTrackColor: inactiveColor,
            disabledActiveTickMarkColor: inactiveColor,
            thumbColor: selectedColor,
            disabledThumbColor: selectedColor,
            inactiveTrackColor: inactiveColor,
            disabledInactiveTrackColor: inactiveColor,
            disabledInactiveTickMarkColor: inactiveColor,
          ),
          child: Slider(
            value: clampedValue,
            max: maxValue,
            divisions: divisions > 0 ? divisions : null,
            // label: (steps > 0 && idx >= 0 && idx < steps) ? hintText[idx] : '',
            activeColor: inactiveColor,
            inactiveColor: inactiveColor,
            thumbColor: selectedColor,
            onChanged: divisions == 0
                ? null
                : (double v) {
                    setState(() => _currentSliderValue = v);
                  },
          ),
        ),
      ],
    );
  }
}

double _segmentWidth(int steps, double totalWidth) {
  if (steps <= 1) return totalWidth;
  return totalWidth / (steps);
}

double _labelX(int index, int steps, double trackUsable, double fullWidth) {
  if (steps <= 1) return 0;
  final double fraction = index / (steps - 1); // 0..1
  final double centerX = fraction * trackUsable;
  final double segWidth = _segmentWidth(steps, trackUsable);
  double left = centerX - segWidth / 2;
  // Clamp within bounds
  if (left < 0) left = 0;
  if (left + segWidth > fullWidth) left = fullWidth - segWidth;
  return left;
}

List<double> _measureLabelWidths(
  List<String> labels,
  TextStyle style,
  double maxWidth,
) {
  final List<double> out = <double>[];
  for (final String text in labels) {
    final TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    out.add(tp.size.width + 4); // small padding
  }
  return out;
}

class _LabelMetrics {
  final double width;
  final TextPainter painter;
  _LabelMetrics({required this.width, required this.painter});
}

class SliderThumbShape extends SliderComponentShape {
  final Color thumbColor;
  const SliderThumbShape({
    this.enabledThumbRadius = 8.0,
    this.disabledThumbRadius = 8,
    this.elevation = 1.0,
    this.pressedElevation = 6.0,
    required this.thumbColor,
  });

  final double enabledThumbRadius;
  final double disabledThumbRadius;

  double get _disabledThumbRadius => disabledThumbRadius;
  final double elevation;
  final double pressedElevation;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(
      isEnabled == true ? enabledThumbRadius : _disabledThumbRadius,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double>? activationAnimation,
    required Animation<double> enableAnimation,
    bool? isDiscrete,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);
    assert(!sizeWithOverflow!.isEmpty);

    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );

    final double radius = radiusTween.evaluate(enableAnimation);

    {
      Paint paint = Paint()..color = sliderTheme.thumbColor!;
      paint.strokeWidth = 7;
      paint.style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius, paint);
      {
        Paint paint = Paint()..color = thumbColor;
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(center, radius, paint);
      }
    }
  }
}

class SliderTickMarkCircle extends SliderTickMarkShape {
  const SliderTickMarkCircle({
    this.tickMarkRadius,
    this.enabledThumbRadius = 6,
    this.disabledThumbRadius = 6,
  });

  final double? tickMarkRadius;
  final double enabledThumbRadius;
  final double disabledThumbRadius;
  double get _disabledThumbRadius => disabledThumbRadius;

  @override
  Size getPreferredSize({
    required SliderThemeData sliderTheme,
    required bool isEnabled,
  }) {
    assert(sliderTheme.trackHeight != null);
    return Size.fromRadius(tickMarkRadius ?? sliderTheme.trackHeight! / 4);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    required bool isEnabled,
  }) {
    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );

    final double radius = radiusTween.evaluate(enableAnimation);

    Paint paint = Paint()..color = sliderTheme.activeTrackColor!;
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paint);
    {
      Paint paint = Paint()..color = sliderTheme.disabledActiveTickMarkColor!;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, paint);
    }
    /*final Paint paint = Paint()
      ..color = ColorTween(begin: begin, end: end).evaluate(enableAnimation)!;

    final double tickMarkRadius = getPreferredSize(
          isEnabled: isEnabled,
          sliderTheme: sliderTheme,
        ).width /
        2;
    if (tickMarkRadius > 0) {
      context.canvas.drawLine(Offset(center.dx - 5, center.dy - 5),
          Offset(center.dx + 5, center.dy + 5), paint);
    }*/
  }
}

class LineSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  /// Creates a slider track that draws 2 rectangles.
  const LineSliderTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting can be a no-op.
    if (sliderTheme.trackHeight! <= 0) {
      return;
    }

    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final ColorTween activeTrackColorTween = ColorTween(
      begin: sliderTheme.disabledActiveTrackColor,
      end: sliderTheme.activeTrackColor,
    );
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final (Paint leftTrackPaint, Paint rightTrackPaint) = (
      activePaint,
      inactivePaint,
    );

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Rect leftTrackSegment = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
    );

    context.canvas.drawRect(leftTrackSegment, leftTrackPaint);
  }
}
