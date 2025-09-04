import 'package:flutter/material.dart';
import 'custom_indicator_builder.dart';

class ValueHolder<T> {
  final T value;

  /// The index of [value] in [values].
  ///
  /// If [values] does not contain [value], this value is set to [-1].
  final int index;

  ValueHolder({required this.value, required this.index});
}

class GlobalToggleProperties<T> {
  /// The position of the indicator relative to the indices of the values.
  final double position;

  /// The current value which is given to the switch.
  ///
  /// Helpful if the value is generated e.g.
  /// when the switch constructor is called.
  final T current;

  /// The index of [current] in [values].
  ///
  /// If [values] does not contain [current], [currentIndex] is set to [-1].
  final int currentIndex;

  /// This value indicates if [values] does contain [current].
  bool get isCurrentListed => currentIndex >= 0;

  /// The previous value of the switch.
  final T? previous;

  /// The values which are given to the switch.
  ///
  /// Helpful if the list is generated e.g.
  /// when the switch constructor is called.
  final List<T> values;

  /// The previous position of the indicator relative
  /// to the indices of the values.
  final double previousPosition;

  /// The [TextDirection] of the switch.
  final TextDirection textDirection;

  /// The current [ToggleMode] of the switch.
  final ToggleMode mode;

  /// Indicates the progress of the loading animation.
  /// [0] means 'not loading' and [1] means 'loading'.
  final double loadingAnimationValue;

  final bool active;

  /// This animation indicates whether the indicator is currently visible.
  ///
  /// [0.0] means it is not visible.
  ///
  /// [1.0] means it is fully visible.
  ///
  /// Depending on the curve of the animation, the value can also be below 0.0 or above 1.0.
  ///
  /// This will be publicly accessible in future releases.
  final Animation<double> indicatorAppearingAnimation;

  const GlobalToggleProperties({
    required this.position,
    required this.current,
    required this.currentIndex,
    required this.previous,
    required this.values,
    required this.previousPosition,
    required this.textDirection,
    required this.mode,
    required this.loadingAnimationValue,
    required this.active,
    required Animation<double> indicatorAppearingAnimation,
  }) : indicatorAppearingAnimation = indicatorAppearingAnimation;
}

class DetailedGlobalToggleProperties<T> extends GlobalToggleProperties<T> {
  /// The final width of the space between the icons.
  ///
  /// May differ from the value passed to the switch.
  final double spacing;

  /// The final size of the indicator.
  ///
  /// May differ from the value passed to the switch.
  final Size indicatorSize;

  /// The size of the switch exclusive the outer wrapper
  final Size switchSize;

  Size get spacingSize => Size(spacing, switchSize.height);

  const DetailedGlobalToggleProperties({
    required this.spacing,
    required this.indicatorSize,
    required this.switchSize,
    required super.position,
    required super.current,
    required super.currentIndex,
    required super.previous,
    required super.values,
    required super.previousPosition,
    required super.textDirection,
    required super.mode,
    required super.loadingAnimationValue,
    required super.active,
    required super.indicatorAppearingAnimation,
  });
}

class LocalToggleProperties<T> {
  /// The value.
  final T value;

  /// The index of [value].
  ///
  /// If [values] does not contain [value], this [index] is set to [-1].
  final int index;

  /// This value indicates if [values] does contain [value].
  bool get isValueListed => index >= 0;

  const LocalToggleProperties({
    required this.value,
    required this.index,
  });
}

class StyledToggleProperties<T> extends LocalToggleProperties<T> {
  //TODO: Add style to this class

  const StyledToggleProperties({
    required super.value,
    required super.index,
  });
}

class AnimatedToggleProperties<T> extends StyledToggleProperties<T> {
  /// A value between [0] and [1].
  ///
  /// [0] indicates that [value] is not selected.
  ///
  /// [1] indicates that [value] is selected.
  final double animationValue;

  AnimatedToggleProperties.fromLocal({
    required this.animationValue,
    required LocalToggleProperties<T> properties,
  }) : super(value: properties.value, index: properties.index);

  const AnimatedToggleProperties({
    required super.value,
    required super.index,
    required this.animationValue,
  });

  AnimatedToggleProperties<T> copyWith({T? value, int? index}) {
    return AnimatedToggleProperties(
        value: value ?? this.value,
        index: index ?? this.index,
        animationValue: animationValue);
  }
}

class RollingProperties<T> extends StyledToggleProperties<T> {
  /// Indicates if the icon is in the foreground.
  ///
  /// For [RollingIconBuilder] it indicates if the icon will be on the indicator
  /// or in the background.
  final bool foreground;

  RollingProperties.fromLocal({
    required bool foreground,
    required LocalToggleProperties<T> properties,
  }) : this(
    foreground: foreground,
    value: properties.value,
    index: properties.index,
  );

  const RollingProperties({
    required this.foreground,
    required super.value,
    required super.index,
  });
}

class SeparatorProperties<T> {
  /// Index of the separator.
  ///
  /// The separator is located  between the items at [index] and [index+1].
  final int index;

  /// The position of the separator relative to the indices of the values.
  double get position => index + 0.5;

  const SeparatorProperties({
    required this.index,
  });
}

class TapProperties<T> {
  /// Information about the point on which the user has tapped.
  ///
  /// This value can be [null] if the user taps on the border of an
  /// [AnimatedToggleSwitch] or on the wrapper of a
  /// [CustomAnimatedToggleSwitch].
  final TapInfo<T>? tapped;

  /// The values which are given to the switch.
  ///
  /// Helpful if the list is generated e.g.
  /// when the switch constructor is called.
  final List<T> values;

  const TapProperties({
    required this.tapped,
    required this.values,
  });
}

class TogglePosition<T> {
  /// The value next to [position].
  final T value;

  /// The index of [value] in [values].
  ///
  /// [index == position.round()] should always be [true].
  final int index;

  /// The position relative to the indices of the values.
  ///
  /// [position] can be in the interval from [-0.5] to [values.length - 0.5].
  ///
  /// [position.round() == index] should always be [true].
  final double position;

  TogglePosition({
    required this.value,
    required this.index,
    required this.position,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PositionListenerInfo &&
              runtimeType == other.runtimeType &&
              value == other.mode &&
              index == other.index &&
              position == other.position;

  @override
  int get hashCode => value.hashCode ^ index.hashCode ^ position.hashCode;
}

class TapInfo<T> extends TogglePosition<T> {
  TapInfo({
    required super.value,
    required super.index,
    required super.position,
  });

  TapInfo.fromPosition(TogglePosition<T> position)
      : this(
    value: position.value,
    index: position.index,
    position: position.position,
  );
}

class PositionListenerInfo<T> extends TogglePosition<T> {
  final ToggleMode mode;

  PositionListenerInfo({
    required super.value,
    required super.index,
    required super.position,
    required this.mode,
  });

  PositionListenerInfo.fromPosition(
      TogglePosition<T> position, ToggleMode mode)
      : this(
    value: position.value,
    index: position.index,
    position: position.position,
    mode: mode,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PositionListenerInfo &&
              runtimeType == other.runtimeType &&
              value == other.value &&
              index == other.index &&
              position == other.position &&
              mode == other.mode;

  @override
  int get hashCode =>
      value.hashCode ^ index.hashCode ^ position.hashCode ^ mode.hashCode;
}