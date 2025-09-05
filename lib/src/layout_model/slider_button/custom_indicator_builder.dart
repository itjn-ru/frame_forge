import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'animations.dart';
import 'cursor.dart';
import 'drag_region.dart';
import 'properties.dart';

typedef CustomIconBuilder<T> =
    Widget Function(
      BuildContext context,
      LocalToggleProperties<T> local,
      DetailedGlobalToggleProperties<T> global,
    );

/// Custom builder for the indicator of the switch.
typedef CustomIndicatorBuilder<T> =
    Widget Function(
      BuildContext context,
      DetailedGlobalToggleProperties<T> global,
    );

/// Custom builder for the wrapper of the switch.
typedef CustomWrapperBuilder<T> =
    Widget Function(
      BuildContext context,
      GlobalToggleProperties<T> global,
      Widget child,
    );

/// Custom builder for the [spacing] section between the icons.
typedef CustomSeparatorBuilder<T> =
    Widget Function(
      BuildContext context,
      SeparatorProperties<T> local,
      DetailedGlobalToggleProperties<T> global,
    );

/// Custom builder for the appearing animation of the indicator.
///
/// If [value] is [0.0], the indicator is completely disappeared.
///
/// If [value] is [1.0], the indicator is fully appeared.
typedef IndicatorAppearingBuilder =
    Widget Function(BuildContext context, double value, Widget indicator);

typedef ChangeCallback<T> = FutureOr<void> Function(T value);

typedef TapCallback<T> = FutureOr<void> Function(TapProperties<T> props);

/// Listener for the current position and [ToggleMode] of the indicator.
typedef PositionListener<T> = void Function(PositionListenerInfo<T> position);

enum ToggleMode { animating, dragged, none }

enum FittingMode { none, preventHorizontalOverlapping }

// global parameter default values
const defaultIndicatorAppearingAnimationDuration = Duration(milliseconds: 400);
const defaultIndicatorAppearingAnimationCurve = Curves.easeOutBack;

Widget defaultIndicatorAppearingBuilder(
  BuildContext context,
  double value,
  Widget indicator,
) {
  return Transform.scale(scale: value, child: indicator);
}

enum IconArrangement {
  /// Indicates that the icons should be in a row.
  ///
  /// This is the default setting.
  row,

  /// Indicates that the icons should overlap.
  /// Normally you don't need this setting.
  ///
  /// This is used for example with [AnimatedToggleSwitch.dual],
  /// because the texts partially overlap here.
  overlap,
}

/// With this widget you can implement your own switches with nice animations.
///
/// For pre-made switches, please use the constructors of [AnimatedToggleSwitch]
/// instead.
class CustomAnimatedToggleSwitch<T extends Object?> extends StatefulWidget {
  /// The currently selected value. It has to be set at [onChanged] or whenever for animating to this value.
  ///
  /// [current] has to be in [values] for working correctly if [allowUnlistedValues] is false.
  final T current;

  /// All selectable values.
  final List<T> values;

  /// The builder for the wrapper around the switch.
  final CustomWrapperBuilder<T>? wrapperBuilder;

  /// The builder for all icons.
  final CustomIconBuilder<T> iconBuilder;

  /// A builder for an indicator which is in front of the icons.
  final CustomIndicatorBuilder<T>? foregroundIndicatorBuilder;

  /// A builder for an indicator which is in behind the icons.
  final CustomIndicatorBuilder<T>? backgroundIndicatorBuilder;

  /// Custom builder for the appearing animation of the indicator.
  ///
  /// If you want to use this feature, you have to set [allowUnlistedValues] to [true].
  ///
  /// An indicator can appear if [current] was previously not contained in [values].
  final IndicatorAppearingBuilder indicatorAppearingBuilder;

  /// Duration of the motion animation.
  final Duration animationDuration;

  /// Curve of the motion animation.
  final Curve animationCurve;

  /// Duration of the loading animation.
  ///
  /// Defaults to [animationDuration].
  final Duration? loadingAnimationDuration;

  /// Curve of the loading animation.
  ///
  /// Defaults to [animationCurve].
  final Curve? loadingAnimationCurve;

  /// Duration of the appearing animation.
  final Duration indicatorAppearingDuration;

  /// Curve of the appearing animation.
  final Curve indicatorAppearingCurve;

  /// Size of the indicator.
  final Size indicatorSize;

  /// Callback for selecting a new value. The new [current] should be set here.
  final ChangeCallback<T>? onChanged;

  /// Space between adjacent icons.
  ///
  /// This value can only be negative if [iconArrangement] is set to [IconArrangement.overlap].
  final double spacing;

  /// Builder for divider or other separators between the icons.
  /// Builder for divider or other separators between the icons.
  ///
  /// The available width is specified by [spacing].
  ///
  /// This builder is supported by [IconArrangement.row] only.
  final CustomSeparatorBuilder<T>? separatorBuilder;

  /// Callback for tapping anywhere on the widget.
  final TapCallback<T>? onTap;

  /// Indicates if [onChanged] is called when an icon is tapped.
  ///
  /// If set to [false], the user can trigger [onChanged]
  /// only by dragging the indicator.
  final bool iconsTappable;

  /// Indicates if the icons should overlap.
  ///
  /// Defaults to [IconArrangement.row] because it fits the most use cases.
  final IconArrangement iconArrangement;

  /// The [FittingMode] of the switch.
  ///
  /// Change this only if you don't want the switch to adjust if the constraints are too small.
  final FittingMode fittingMode;

  /// The height of the whole switch including wrapper.
  final double height;

  /// A padding between wrapper and icons/indicator.
  final EdgeInsetsGeometry padding;

  /// The minimum width of the indicator's hitbox.
  ///
  /// Helpful if the indicator is so small that you can hardly grip it.
  final double minTouchTargetSize;

  /// The duration for the animation to the thumb when the user starts dragging.
  final Duration dragStartDuration;

  /// The curve for the animation to the thumb when the user starts dragging.
  final Curve dragStartCurve;

  /// The direction in which the icons are arranged.
  ///
  /// If set to [null], the [TextDirection] is taken from the [BuildContext].
  final TextDirection? textDirection;

  /// The [MouseCursor] settings for this switch.
  final ToggleCursors cursors;

  /// Indicates if the switch is currently loading.
  ///
  /// If set to [null], the switch is loading automatically when a [Future] is
  /// returned by [onChanged] or [onTap].
  final bool? loading;

  /// Indicates if an error should be thrown if [current] is not in [values].
  ///
  /// If [allowUnlistedValues] is [true] and [values] does not contain [current],
  /// the indicator disappears with the specified [indicatorAppearingBuilder].
  final bool allowUnlistedValues;

  /// Indicates if the switch is active.
  final bool active;

  /// Listener for the current position and [ToggleMode] of the indicator.
  final PositionListener<T>? positionListener;

  const CustomAnimatedToggleSwitch({
    super.key,
    required this.current,
    required this.values,
    required this.iconBuilder,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOutCirc,
    this.indicatorSize = const Size(48.0, double.infinity),
    this.onChanged,
    this.spacing = 0.0,
    this.separatorBuilder,
    this.onTap,
    this.fittingMode = FittingMode.preventHorizontalOverlapping,
    this.wrapperBuilder,
    this.foregroundIndicatorBuilder,
    this.backgroundIndicatorBuilder,
    this.indicatorAppearingBuilder = defaultIndicatorAppearingBuilder,
    this.height = 50.0,
    this.iconArrangement = IconArrangement.row,
    this.iconsTappable = true,
    this.padding = EdgeInsets.zero,
    this.minTouchTargetSize = 48.0,
    this.dragStartDuration = const Duration(milliseconds: 200),
    this.dragStartCurve = Curves.easeInOutCirc,
    this.textDirection,
    this.cursors = const ToggleCursors(),
    this.loading,
    this.loadingAnimationDuration,
    this.loadingAnimationCurve,
    this.indicatorAppearingDuration =
        defaultIndicatorAppearingAnimationDuration,
    this.indicatorAppearingCurve = defaultIndicatorAppearingAnimationCurve,
    this.allowUnlistedValues = false,
    this.active = true,
    this.positionListener,
  }) : assert(
         foregroundIndicatorBuilder != null ||
             backgroundIndicatorBuilder != null,
       ),
       assert(
         separatorBuilder == null ||
             (spacing > 0 && iconArrangement == IconArrangement.row),
       );

  @override
  State<CustomAnimatedToggleSwitch<T>> createState() =>
      CustomAnimatedToggleSwitchState<T>();
}

class CustomAnimatedToggleSwitchState<T>
    extends State<CustomAnimatedToggleSwitch<T>>
    with TickerProviderStateMixin {
  /// The [AnimationController] for the movement of the indicator.
  late final AnimationController _controller;

  /// The [AnimationController] for the appearing of the indicator.
  late final AnimationController _appearingController;

  /// The [Animation] for the movement of the indicator.
  late final CurvedAnimation _animation;

  /// The [Animation] for the appearing of the indicator.
  late final CurvedAnimation _appearingAnimation;

  /// The current state of the movement of the indicator.
  late AnimationInfo _animationInfo;

  /// This list contains the last [Future]s returned by [widget.onTap] and [widget.onChanged].
  final List<Future<void>> _loadingFutures = [];

  late int _currentIndex;

  bool get _isCurrentUnlisted => _currentIndex < 0;

  double get _positionValue => _animationInfo
      .valueAt(_animation.value)
      .clamp(0, widget.values.length - 1);

  PositionListenerInfo<T>? _lastPositionListenerValue;

  @override
  void initState() {
    super.initState();

    final current = widget.current;
    final isValueSelected = widget.values.contains(current);
    _currentIndex = widget.values.indexOf(current);
    _checkForUnlistedValue();
    _animationInfo = AnimationInfo(
      isValueSelected ? _currentIndex.toDouble() : 0.0,
    ).setLoading(widget.loading ?? false);
    _controller =
        AnimationController(vsync: this, duration: widget.animationDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed &&
                _animationInfo.toggleMode != ToggleMode.dragged) {
              _setAnimationInfo(_animationInfo.ended());
            }
          });

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    )..addListener(_callPositionListener);

    _appearingController = AnimationController(
      vsync: this,
      duration: widget.indicatorAppearingDuration,
      value: isValueSelected ? 1.0 : 0.0,
    );

    _appearingAnimation = CurvedAnimation(
      parent: _appearingController,
      curve: widget.indicatorAppearingCurve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _appearingController.dispose();
    super.dispose();
  }

  @pragma('vm:notify-debugger-on-exception')
  void _checkForUnlistedValue() {
    if (!widget.allowUnlistedValues &&
        !widget.values.contains(widget.current)) {
      try {
        throw ArgumentError(
          'The values in AnimatedToggleSwitch have to contain current if allowUnlistedValues is false.\n'
          'current: ${widget.current}\n'
          'values: ${widget.values}\n'
          'This error is only thrown in debug mode to minimize problems with the production app.',
        );
      } catch (e, s) {
        if (kDebugMode) rethrow;
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: e,
            stack: s,
            library: 'AnimatedToggleSwitch',
          ),
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant CustomAnimatedToggleSwitch<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkForUnlistedValue();

    _appearingController.duration = widget.indicatorAppearingDuration;
    _appearingAnimation.curve = widget.indicatorAppearingCurve;
    _controller.duration = widget.animationDuration;
    _animation.curve = widget.animationCurve;

    if (oldWidget.active && !widget.active) {
      _cancelDrag();
    }
    if (oldWidget.loading != widget.loading) {
      _loading(widget.loading ?? _loadingFutures.isNotEmpty);
    }

    _checkValuePosition();
  }

  bool get _isActive => widget.active && !_animationInfo.loading;

  void _addLoadingFuture(Future<void> future) {
    _loadingFutures.add(future);
    final futureLength = _loadingFutures.length;
    if (widget.loading == null) _loading(true);
    Future.wait(_loadingFutures).whenComplete(() {
      // Check if new future is added since calling method
      if (futureLength != _loadingFutures.length) return;
      if (widget.loading == null && mounted) _loading(false);
      _loadingFutures.clear();
    });
  }

  void _onChanged(T value) {
    if (!_isActive) return;
    final result = widget.onChanged?.call(value);
    if (result is Future) {
      _addLoadingFuture(result);
    }
  }

  /// This method is called in two [GestureDetector]s because only one
  /// [GestureDetector.onTapUp] will be triggered.
  void _onTap(TapProperties<T> info) {
    if (!_isActive) return;
    final result = widget.onTap?.call(info);
    if (result is Future) {
      _addLoadingFuture(result);
    }
  }

  void _loading(bool b) {
    if (b == _animationInfo.loading) return;
    _cancelDrag();
    _setAnimationInfo(_animationInfo.setLoading(b), setState: true);
  }

  /// Checks if the current value has a different position than the indicator
  /// and starts an animation if necessary.
  ///
  /// IMPORTANT: This must be called in [didUpdateWidget] because it updates
  /// [_currentIndex] also.
  void _checkValuePosition() {
    _currentIndex = widget.values.indexOf(widget.current);
    if (_animationInfo.toggleMode == ToggleMode.dragged) return;
    if (_currentIndex >= 0) {
      _animateTo(_currentIndex);
    } else {
      _appearingController.reverse();
    }
  }

  /// Returns the value position by the local position of the cursor.
  /// It is mainly intended as a helper function for the build method.
  double _doubleFromPosition(
    double x,
    DetailedGlobalToggleProperties<T> properties,
  ) {
    double result =
        (x.clamp(
              properties.indicatorSize.width / 2,
              properties.switchSize.width - properties.indicatorSize.width / 2,
            ) -
            properties.indicatorSize.width / 2) /
        (properties.indicatorSize.width + properties.spacing);
    if (properties.textDirection == TextDirection.rtl) {
      result = widget.values.length - 1 - result;
    }
    return result;
  }

  void _setAnimationInfo(AnimationInfo info, {bool setState = false}) {
    if (_animationInfo == info) return;
    _animationInfo = info;
    if (setState) this.setState(() {});
    _callPositionListener();
  }

  void _callPositionListener() {
    if (widget.positionListener == null) return;
    final value = PositionListenerInfo.fromPosition(
      _togglePositionFromPositionValue(_positionValue),
      _animationInfo.toggleMode,
    );
    if (_lastPositionListenerValue == value) return;
    _lastPositionListenerValue = value;
    widget.positionListener?.call(value);
  }

  /// Returns the [TogglePosition] by the position value.
  /// It is mainly intended as a helper function for the build method.
  TogglePosition<T> _togglePositionFromPositionValue(double position) {
    final index = position.round();
    return TogglePosition(
      value: widget.values[index],
      index: index,
      position: position,
    );
  }

  /// Returns the [TogglePosition] by the local position of the cursor.
  /// It is mainly intended as a helper function for the build method.
  TogglePosition<T> _togglePositionFromRealPosition(
    double x,
    DetailedGlobalToggleProperties<T> properties,
  ) {
    return _togglePositionFromPositionValue(_doubleFromPosition(x, properties));
  }

  @override
  Widget build(BuildContext context) {
    double spacing = widget.spacing;
    final textDirection = _textDirectionOf(context);
    final loadingValue = _animationInfo.loading ? 1.0 : 0.0;
    final privateIndicatorAppearingAnimation = PrivateAnimation(
      _appearingAnimation,
    );

    final defaultCursor = !_isActive
        ? (_animationInfo.loading
              ? widget.cursors.loadingCursor
              : widget.cursors.inactiveCursor)
        : (widget.cursors.defaultCursor ??
              (widget.onTap == null
                  ? MouseCursor.defer
                  : SystemMouseCursors.click));

    return SizedBox(
      height: widget.height,
      child: MouseRegion(
        hitTestBehavior: HitTestBehavior.deferToChild,
        cursor: defaultCursor,
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTapUp: (_) =>
              _onTap(TapProperties(tapped: null, values: widget.values)),
          child: TweenAnimationBuilder<double>(
            duration:
                widget.loadingAnimationDuration ?? widget.animationDuration,
            curve: widget.loadingAnimationCurve ?? widget.animationCurve,
            tween: Tween(begin: loadingValue, end: loadingValue),
            builder: (context, loadingValue, child) => AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                double positionValue = _positionValue;
                GlobalToggleProperties<T> properties = GlobalToggleProperties(
                  position: positionValue,
                  current: widget.current,
                  currentIndex: _currentIndex,
                  previous: _animationInfo.start.toInt() == _animationInfo.start
                      ? widget.values[_animationInfo.start.toInt()]
                      : null,
                  values: widget.values,
                  previousPosition: _animationInfo.start,
                  textDirection: textDirection,
                  mode: _animationInfo.toggleMode,
                  loadingAnimationValue: loadingValue,
                  active: widget.active,
                  indicatorAppearingAnimation:
                      privateIndicatorAppearingAnimation,
                );
                Widget child = Padding(
                  padding: widget.padding,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double height = constraints.maxHeight;
                      assert(
                        constraints.maxWidth.isFinite ||
                            (widget.indicatorSize.width.isFinite &&
                                spacing.isFinite),
                        'With unbound width constraints '
                        'the width of the indicator and the spacing '
                        "can't be infinite",
                      );
                      assert(
                        widget.indicatorSize.width.isFinite || spacing.isFinite,
                        'The width of the indicator '
                        'or the spacing must be finite.',
                      );

                      // Recalculates the indicatorSize if its width or height is
                      // infinite.
                      Size indicatorSize = Size(
                        widget.indicatorSize.width.isInfinite
                            ? (constraints.maxWidth -
                                      spacing * (widget.values.length - 1)) /
                                  widget.values.length
                            : widget.indicatorSize.width,
                        widget.indicatorSize.height.isInfinite
                            ? height
                            : widget.indicatorSize.height,
                      );

                      if (spacing.isInfinite) {
                        spacing =
                            (constraints.maxWidth -
                                widget.indicatorSize.width *
                                    widget.values.length) /
                            (widget.values.length - 1);
                      }

                      // Calculates the required width of the widget.
                      double width =
                          indicatorSize.width * widget.values.length +
                          (widget.values.length - 1) * spacing;

                      // Handles the case that the required width of the widget
                      // cannot be used due to the given BoxConstraints.
                      if (widget.fittingMode ==
                              FittingMode.preventHorizontalOverlapping &&
                          width > constraints.maxWidth) {
                        double factor = constraints.maxWidth / width;
                        spacing *= factor;
                        width = constraints.maxWidth;
                        indicatorSize = Size(
                          indicatorSize.width.isInfinite
                              ? width / widget.values.length
                              : factor * indicatorSize.width,
                          indicatorSize.height,
                        );
                      } else if (constraints.minWidth > width) {
                        spacing +=
                            (constraints.minWidth - width) /
                            (widget.values.length - 1);
                        width = constraints.minWidth;
                      }

                      // The additional width of the indicator's hitbox needed
                      // to reach the minTouchTargetSize.
                      double dragDif =
                          indicatorSize.width < widget.minTouchTargetSize
                          ? (widget.minTouchTargetSize - indicatorSize.width)
                          : 0;

                      // The local position of the indicator.
                      double position =
                          (indicatorSize.width + spacing) * positionValue +
                          indicatorSize.width / 2;

                      double leftPosition = textDirection == TextDirection.rtl
                          ? width - position
                          : position;

                      bool isHoveringIndicator(Offset offset) {
                        if (!_isActive || _isCurrentUnlisted) {
                          return false;
                        }
                        double dx = textDirection == TextDirection.rtl
                            ? width - offset.dx
                            : offset.dx;
                        return position - (indicatorSize.width + dragDif) / 2 <=
                                dx &&
                            dx <=
                                (position +
                                    (indicatorSize.width + dragDif) / 2);
                      }

                      DetailedGlobalToggleProperties<T> properties =
                          DetailedGlobalToggleProperties(
                            spacing: spacing,
                            position: positionValue,
                            indicatorSize: indicatorSize,
                            switchSize: Size(width, height),
                            current: widget.current,
                            currentIndex: _currentIndex,
                            previous:
                                _animationInfo.start.toInt() ==
                                    _animationInfo.start
                                ? widget.values[_animationInfo.start.toInt()]
                                : null,
                            values: widget.values,
                            previousPosition: _animationInfo.start,
                            textDirection: textDirection,
                            mode: _animationInfo.toggleMode,
                            loadingAnimationValue: loadingValue,
                            active: widget.active,
                            indicatorAppearingAnimation:
                                privateIndicatorAppearingAnimation,
                          );

                      List<Widget> stack = <Widget>[
                        if (widget.backgroundIndicatorBuilder != null)
                          Indicator(
                            key: const ValueKey(0),
                            textDirection: textDirection,
                            height: height,
                            indicatorSize: indicatorSize,
                            position: position,
                            appearingAnimation: _appearingAnimation,
                            appearingBuilder: widget.indicatorAppearingBuilder,
                            child: widget.backgroundIndicatorBuilder!(
                              context,
                              properties,
                            ),
                          ),
                        if (widget.iconArrangement == IconArrangement.overlap)
                          ..._buildBackgroundStack(context, properties)
                        else
                          ..._buildBackgroundRow(context, properties),
                        if (widget.foregroundIndicatorBuilder != null)
                          Indicator(
                            key: const ValueKey(1),
                            textDirection: textDirection,
                            height: height,
                            indicatorSize: indicatorSize,
                            position: position,
                            appearingAnimation: _appearingAnimation,
                            appearingBuilder: widget.indicatorAppearingBuilder,
                            child: widget.foregroundIndicatorBuilder!(
                              context,
                              properties,
                            ),
                          ),
                      ];

                      return WidgetPart(
                        left:
                            loadingValue *
                            (leftPosition - 0.5 * indicatorSize.width),
                        width:
                            indicatorSize.width +
                            (1 - loadingValue) * (width - indicatorSize.width),
                        height: height,
                        child: ConstrainedBox(
                          constraints: constraints.loosen(),
                          child: SizedBox(
                            width: width,
                            height: height,
                            // manual check if cursor is above indicator
                            // to make sure that GestureDetector and MouseRegion match.
                            // TODO: one widget for DragRegion and GestureDetector to avoid redundancy
                            child: HoverRegion(
                              hoverCursor: widget.cursors.tapCursor,
                              hoverCheck: (pos) =>
                                  widget.iconsTappable &&
                                  _doubleFromPosition(
                                        pos.dx,
                                        properties,
                                      ).round() !=
                                      _currentIndex,
                              child: DragRegion(
                                dragging:
                                    _animationInfo.toggleMode ==
                                    ToggleMode.dragged,
                                draggingCursor: widget.cursors.draggingCursor,
                                dragCursor: widget.cursors.dragCursor,
                                hoverCheck: isHoveringIndicator,
                                defaultCursor: defaultCursor,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  dragStartBehavior: DragStartBehavior.down,
                                  onTapUp: (details) {
                                    final togglePosition =
                                        _togglePositionFromRealPosition(
                                          details.localPosition.dx,
                                          properties,
                                        );
                                    _onTap(
                                      TapProperties(
                                        tapped: TapInfo.fromPosition(
                                          togglePosition,
                                        ),
                                        values: widget.values,
                                      ),
                                    );
                                    if (!widget.iconsTappable) return;
                                    if (togglePosition.value ==
                                        widget.current) {
                                      return;
                                    }
                                    _onChanged(togglePosition.value);
                                  },
                                  onHorizontalDragStart: (details) {
                                    if (!isHoveringIndicator(
                                      details.localPosition,
                                    )) {
                                      return;
                                    }
                                    _onDragged(
                                      _doubleFromPosition(
                                        details.localPosition.dx,
                                        properties,
                                      ),
                                      positionValue,
                                    );
                                  },
                                  onHorizontalDragUpdate: (details) {
                                    _onDragUpdate(
                                      _doubleFromPosition(
                                        details.localPosition.dx,
                                        properties,
                                      ),
                                    );
                                  },
                                  onHorizontalDragEnd: (details) {
                                    _onDragEnd();
                                  },
                                  // DecoratedBox for gesture detection
                                  child: DecoratedBox(
                                    position: DecorationPosition.background,
                                    decoration: const BoxDecoration(),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: stack,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
                return widget.wrapperBuilder?.call(
                      context,
                      properties,
                      child,
                    ) ??
                    child;
              },
            ),
          ),
        ),
      ),
    );
  }

  /// The builder of the icons for [IconArrangement.overlap].
  List<Widget> _buildBackgroundStack(
    BuildContext context,
    DetailedGlobalToggleProperties<T> properties,
  ) {
    return [
      ...Iterable.generate(widget.values.length, (i) {
        double position =
            i * (properties.indicatorSize.width + properties.spacing);
        return Positioned.directional(
          textDirection: _textDirectionOf(context),
          start: i == 0 ? position : position - properties.spacing,
          width:
              (i == 0 || i == widget.values.length - 1 ? 1 : 2) *
                  properties.spacing +
              properties.indicatorSize.width,
          height: properties.indicatorSize.height,
          child: widget.iconBuilder(
            context,
            LocalToggleProperties(value: widget.values[i], index: i),
            properties,
          ),
        );
      }),
      // shows horizontal overlapping for FittingMode.none in debug mode
      Row(
        children: [SizedBox(width: properties.switchSize.width, height: 1.0)],
      ),
    ];
  }

  /// The builder of the icons for [IconArrangement.row].
  List<Widget> _buildBackgroundRow(
    BuildContext context,
    DetailedGlobalToggleProperties<T> properties,
  ) {
    final length = properties.values.length;
    return [
      Row(
        textDirection: _textDirectionOf(context),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < length; i++) ...[
            SizedBox(
              width: properties.indicatorSize.width,
              height: properties.indicatorSize.height,
              child: widget.iconBuilder(
                context,
                LocalToggleProperties(value: widget.values[i], index: i),
                properties,
              ),
            ),
            if (i < length - 1 && widget.separatorBuilder != null)
              SizedBox(
                width: properties.spacing,
                child: Center(
                  child: widget.separatorBuilder!(
                    context,
                    SeparatorProperties(index: i),
                    properties,
                  ),
                ),
              ),
          ],
        ],
      ),
    ];
  }

  /// Animates the indicator to a specific item by its index.
  void _animateTo(int index, {double? current}) {
    if (_animationInfo.toggleMode == ToggleMode.dragged) return;
    if (_appearingController.value > 0.0) {
      if (index.toDouble() != _animationInfo.end) {
        _setAnimationInfo(
          _animationInfo.toEnd(
            index.toDouble(),
            current: current ?? _animationInfo.valueAt(_animation.value),
          ),
        );
        _controller.duration = widget.animationDuration;
        _animation.curve = widget.animationCurve;
        _controller.forward(from: 0.0);
      }
    } else {
      _setAnimationInfo(_animationInfo.toEnd(index.toDouble()).ended());
    }
    _appearingController.forward();
  }

  /// Starts the dragging of the indicator and starts the animation to
  /// the current cursor position.
  void _onDragged(double indexPosition, double pos) {
    if (!_isActive) return;
    _setAnimationInfo(_animationInfo.dragged(indexPosition, pos: pos));
    _controller.duration = widget.dragStartDuration;
    _animation.curve = widget.dragStartCurve;
    _controller.forward(from: 0.0);
  }

  /// Updates the current drag position.
  void _onDragUpdate(double indexPosition) {
    if (_animationInfo.toggleMode != ToggleMode.dragged) return;
    _setAnimationInfo(_animationInfo.dragged(indexPosition), setState: true);
  }

  /// Ends the dragging of the indicator and starts an animation
  /// to the new value if necessary.
  void _onDragEnd() {
    if (_animationInfo.toggleMode != ToggleMode.dragged) return;
    int index = _animationInfo.end.round();
    T newValue = widget.values[index];
    _setAnimationInfo(_animationInfo.none(current: _animationInfo.end));
    if (widget.current != newValue) _onChanged(newValue);
    _checkValuePosition();
  }

  /// Cancels drag because of loading or inactivity
  void _cancelDrag() {
    _setAnimationInfo(_animationInfo.none());
    _checkValuePosition();
  }

  /// Returns the [TextDirection] of the widget.
  TextDirection _textDirectionOf(BuildContext context) =>
      widget.textDirection ??
      Directionality.maybeOf(context) ??
      TextDirection.ltr;
}

/// The [Positioned] for an indicator. It is used as wrapper for
/// [CustomAnimatedToggleSwitch.foregroundIndicatorBuilder] and
/// [CustomAnimatedToggleSwitch.backgroundIndicatorBuilder].
class Indicator extends StatelessWidget {
  final double height;
  final Size indicatorSize;
  final double position;
  final Widget child;
  final TextDirection textDirection;
  final Animation<double> appearingAnimation;
  final IndicatorAppearingBuilder appearingBuilder;

  const Indicator({
    super.key,
    required this.height,
    required this.indicatorSize,
    required this.position,
    required this.textDirection,
    required this.appearingAnimation,
    required this.appearingBuilder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.directional(
      textDirection: textDirection,
      top: (height - indicatorSize.height) / 2,
      start: position - indicatorSize.width / 2,
      width: indicatorSize.width,
      height: indicatorSize.height,
      child: AnimatedBuilder(
        animation: appearingAnimation,
        builder: (context, _) {
          return appearingBuilder(context, appearingAnimation.value, child);
        },
      ),
    );
  }
}

class WidgetPart extends StatelessWidget {
  final double width, height;
  final double left;
  final Widget child;

  const WidgetPart({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
    required this.left,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OverflowBox(
        alignment: Alignment.topLeft,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Transform.translate(offset: Offset(-left, 0), child: child),
      ),
    );
  }
}

/// A class for holding the current state of [CustomAnimatedToggleSwitchState].
class AnimationInfo {
  /// The start position of the current animation.
  final double start;

  /// The end position of the current animation.
  final double end;

  final ToggleMode toggleMode;
  final bool loading;

  const AnimationInfo(
    this.start, {
    this.toggleMode = ToggleMode.none,
    this.loading = false,
  }) : end = start;

  const AnimationInfo._internal(
    this.start,
    this.end, {
    this.toggleMode = ToggleMode.none,
    this.loading = false,
  });

  const AnimationInfo.animating(this.start, this.end, {this.loading = false})
    : toggleMode = ToggleMode.animating;

  AnimationInfo toEnd(double end, {double? current}) =>
      AnimationInfo.animating(current ?? start, end, loading: loading);

  AnimationInfo none({double? current}) => AnimationInfo(
    current ?? start,
    toggleMode: ToggleMode.none,
    loading: loading,
  );

  AnimationInfo ended() => AnimationInfo(end, loading: loading);

  AnimationInfo dragged(double current, {double? pos}) =>
      AnimationInfo._internal(
        pos ?? start,
        current,
        toggleMode: ToggleMode.dragged,
        loading: false,
      );

  AnimationInfo setLoading(bool loading) => AnimationInfo._internal(
    start,
    end,
    toggleMode: toggleMode,
    loading: loading,
  );

  double valueAt(num position) => start + (end - start) * position;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimationInfo &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end &&
          toggleMode == other.toggleMode &&
          loading == other.loading;

  @override
  int get hashCode =>
      start.hashCode ^ end.hashCode ^ toggleMode.hashCode ^ loading.hashCode;
}
