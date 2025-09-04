import 'dart:math';

import 'package:flutter/material.dart';
import 'animation_type_builder.dart';
import 'cursor.dart';
import 'custom_indicator_builder.dart';
import 'properties.dart';
import 'test_keys.dart';
import 'tweens.dart';

part 'style.dart';

typedef SimpleIconBuilder<T> = Widget Function(T value);


typedef LoadingIconBuilder<T> = Widget Function(
    BuildContext context, DetailedGlobalToggleProperties<T> global);

/// A version of [IconBuilder] for writing a custom animation for the change of the selected item.
typedef AnimatedIconBuilder<T> = Widget Function(
    BuildContext context,
    AnimatedToggleProperties<T> local,
    DetailedGlobalToggleProperties<T> global);

typedef IconBuilder<T> = Widget Function(
    BuildContext context,
    StyledToggleProperties<T> local,
    DetailedGlobalToggleProperties<T> global,
    );

typedef StyleBuilder<T> = ToggleStyle Function(T value);

typedef CustomStyleBuilder<T> = ToggleStyle Function(
    BuildContext context,
    StyledToggleProperties<T> local,
    GlobalToggleProperties<T> global,
    );

typedef SeparatorBuilder = Widget Function(int index);

/// Specifies when an value should be animated.
enum AnimationType {
  /// Disables the animation.
  none,

  /// Starts an animation if an item is selected.
  onSelected,

  /// Starts an animation if an item is hovered by the indicator.
  onHover,
}

/// Super class of [AnimatedToggleSwitch] for holding assertions.
abstract class _AnimatedToggleSwitchParent<T> extends StatelessWidget {
  const _AnimatedToggleSwitchParent({
    super.key,
    required List<T> values,
    required StyleBuilder<T>? styleBuilder,
    required CustomStyleBuilder<T>? customStyleBuilder,
    required List<ToggleStyle>? styleList,
    required List<Widget>? iconList,
  })  : assert(
  (styleBuilder ?? customStyleBuilder) == null ||
      (styleBuilder ?? styleList) == null ||
      (customStyleBuilder ?? styleList) == null,
  'Only one parameter of styleBuilder, customStyleBuilder and styleList can be set.',
  ),
        assert(styleList == null || styleList.length == values.length,
        'styleList must be null or have the same length as values'),
        assert(iconList == null || iconList.length == values.length,
        'iconList must be null or have the same length as values');
}

/// A class with constructors for different switches.
/// The constructors have sensible default values for their parameters,
/// but can also be customized.
///
/// If you want to implement a completely custom switch,
/// you should use [CustomAnimatedToggleSwitch], which is used by
/// [AnimatedToggleSwitch] in the background.
class AnimatedToggleSwitch<T extends Object?>
    extends _AnimatedToggleSwitchParent<T> {
  /// The currently selected value. It has to be set at [onChanged] or whenever for animating to this value.
  ///
  /// [current] has to be in [values] for working correctly if [allowUnlistedValues] is false.
  final T current;

  /// All possible values.
  final List<T> values;

  /// The [IconBuilder] for all icons with the specified size.
  final AnimatedIconBuilder<T>? animatedIconBuilder;

  /// The default style of this switch.
  ///
  /// This value can be overwritten by [styleBuilder].
  final ToggleStyle style;

  /// Builder for the style of the indicator depending on the current value.
  ///
  /// The returned style values overwrite the values of the [style] parameter if not [null].
  ///
  /// For a version of this builder with more parameters, please use [customStyleBuilder].
  final StyleBuilder<T>? styleBuilder;

  /// Custom builder for the style of the indicator.
  ///
  /// The returned style values overwrite the values of the [style] parameter if not [null].
  ///
  /// For a simpler version of this builder, please use [styleBuilder].
  final CustomStyleBuilder<T>? customStyleBuilder;

  /// List of the styles for all values.
  ///
  /// [styleList] must have the same length as [values].
  final List<ToggleStyle>? styleList;

  /// Duration of the motion animation.
  final Duration animationDuration;

  /// If null, [animationDuration] is taken.
  ///
  /// [iconAnimationDuration] defines the duration of the [Animation] built in [animatedIconBuilder].
  /// In some constructors this is the Duration of the size animation.
  final Duration? iconAnimationDuration;

  /// Curve of the motion animation.
  final Curve animationCurve;

  /// [iconAnimationCurve] defines the [Duration] of the [Animation] built in [animatedIconBuilder].
  /// In some constructors this is the [Curve] of the size animation.
  final Curve iconAnimationCurve;

  /// Size of the indicator.
  final Size indicatorSize;

  /// Callback for selecting a new value. The new [current] should be set here.
  final ChangeCallback<T>? onChanged;

  /// Width of the border of the switch. For deactivating please set this to [0.0].
  final double borderWidth;

  /// Opacity for the icons.
  ///
  /// Please set [iconOpacity] and [selectedIconOpacity] to [1.0] for deactivating the AnimatedOpacity.
  final double iconOpacity;

  /// Opacity for the currently selected icon.
  ///
  /// Please set [iconOpacity] and [selectedIconOpacity] to [1.0] for deactivating the AnimatedOpacity.
  final double selectedIconOpacity;

  /// Space between adjacent icons.
  final double spacing;

  /// Total height of the widget.
  final double height;

  /// If null, the indicator is behind the icons. Otherwise an icon is in the indicator and is built using this function.
  final CustomIndicatorBuilder<T>? foregroundIndicatorIconBuilder;

  /// The [AnimationType] for the [animatedIconBuilder].
  final AnimationType iconAnimationType;

  /// The [AnimationType] for [styleBuilder].
  ///
  /// The [AnimationType] for [ToggleStyle.indicatorColor],
  /// [ToggleStyle.indicatorGradient], [ToggleStyle.indicatorBorderRadius],
  /// [ToggleStyle.indicatorBorder] and [ToggleStyle.indicatorBoxShadow].
  /// is managed separately with [indicatorAnimationType].
  final AnimationType styleAnimationType;

  /// The [AnimationType] for [ToggleStyle.indicatorColor],
  /// [ToggleStyle.indicatorGradient], [ToggleStyle.indicatorBorderRadius],
  /// [ToggleStyle.indicatorBorder] and [ToggleStyle.indicatorBoxShadow]
  ///
  /// For the other style parameters, please use [styleAnimationType].
  final AnimationType indicatorAnimationType;

  /// Callback for tapping anywhere on the widget.
  final TapCallback<T>? onTap;

  final IconArrangement _iconArrangement;

  /// The [MouseCursor] settings for this switch.
  final ToggleCursors cursors;

  /// The [FittingMode] of the switch.
  ///
  /// Change this only if you don't want the switch to adjust when the constraints are too small.
  final FittingMode fittingMode;

  /// Indicates if [onChanged] is called when an icon is tapped.
  /// If [false] the user can change the value only by dragging the indicator.
  final bool iconsTappable;

  /// The minimum size of the indicator's hitbox.
  ///
  /// Helpful if the indicator is so small that you can hardly grip it.
  final double minTouchTargetSize;

  /// The direction in which the icons are arranged.
  ///
  /// If [null], the [TextDirection] is taken from the [BuildContext].
  final TextDirection? textDirection;


  /// Indicates that no error should be thrown if [current] is not contained in [values].
  ///
  /// If [allowUnlistedValues] is [true] and [values] does not contain [current],
  /// the indicator disappears with the specified [indicatorAppearingBuilder].
  final bool allowUnlistedValues;

  /// Custom builder for the appearing animation of the indicator.
  ///
  /// If you want to use this feature, you have to set [allowUnlistedValues] to [true].
  ///
  /// An indicator can appear if [current] was previously not contained in [values].
  final IndicatorAppearingBuilder indicatorAppearingBuilder;

  /// Duration of the appearing animation.
  final Duration indicatorAppearingDuration;

  /// Curve of the appearing animation.
  final Curve indicatorAppearingCurve;

  /// Builder for divider or other separators between the icons. Consider using [customSeparatorBuilder] for maximum customizability.
  ///
  /// The available width is specified by [spacing].
  ///
  /// This builder is supported by [IconArrangement.row] only.
  final SeparatorBuilder? separatorBuilder;

  /// Builder for divider or other separators between the icons. Consider using [separatorBuilder] for a simpler builder function.
  ///
  /// The available width is specified by [spacing].
  ///
  /// This builder is supported by [IconArrangement.row] only.
  final CustomSeparatorBuilder<T>? customSeparatorBuilder;

  /// Indicates if the switch is active.
  ///
  /// Please use [inactiveOpacity] for changing the opacity in inactive state.
  ///
  /// For controlling the [AnimatedOpacity] you can use [inactiveOpacityCurve] and [inactiveOpacityDuration].
  final bool active;

  /// Opacity of the switch when [active] is set to [false].
  ///
  /// Please set this to [1.0] for deactivating.
  final double inactiveOpacity;

  /// [Curve] of the animation when getting inactive.
  ///
  /// For deactivating this animation please set [inactiveOpacity] to [1.0].
  final Curve inactiveOpacityCurve;

  /// [Duration] of the animation when getting inactive.
  ///
  /// For deactivating this animation please set [inactiveOpacity] to [1.0].
  final Duration inactiveOpacityDuration;

  /// Listener for the current position and [ToggleMode] of the indicator.
  final PositionListener<T>? positionListener;

  /// [Clip] of the switch wrapper.
  final Clip clipBehavior;

  final bool animateStyleChanges = true;


  /// Provides an [AnimatedToggleSwitch] with the standard size animation of the icons.
  ///
  /// Maximum one argument of [iconBuilder], [customIconBuilder] and [iconList] must be provided.
  ///
  /// Maximum one argument of [styleBuilder], [customStyleBuilder] and [styleList] must be provided.
  AnimatedToggleSwitch.size({
    super.key,
    required this.current,
    required this.values,
    SimpleIconBuilder<T>? iconBuilder,
    AnimatedIconBuilder<T>? customIconBuilder,
    super.iconList,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOutCirc,
    this.indicatorSize = const Size.fromWidth(48.0),
    this.onChanged,
    this.borderWidth = 2.0,
    this.style = const ToggleStyle(),
    this.styleBuilder,
    this.customStyleBuilder,
    this.styleList,
    double selectedIconScale = sqrt2,
    this.iconAnimationCurve = Curves.easeOutBack,
    this.iconAnimationDuration,
    this.iconOpacity = 0.5,
    this.selectedIconOpacity = 1.0,
    this.spacing = 0.0,
    this.foregroundIndicatorIconBuilder,
    this.height = 50.0,
    this.iconAnimationType = AnimationType.onSelected,
    this.styleAnimationType = AnimationType.onSelected,
    this.indicatorAnimationType = AnimationType.onHover,
    this.onTap,
    this.fittingMode = FittingMode.preventHorizontalOverlapping,
    this.minTouchTargetSize = 48.0,
    this.textDirection,
    this.iconsTappable = true,
    this.cursors = const ToggleCursors(),
    this.allowUnlistedValues = false,
    this.indicatorAppearingBuilder = defaultIndicatorAppearingBuilder,
    this.indicatorAppearingDuration =
        defaultIndicatorAppearingAnimationDuration,
    this.indicatorAppearingCurve = defaultIndicatorAppearingAnimationCurve,
    this.separatorBuilder,
    this.customSeparatorBuilder,
    this.active = true,
    this.inactiveOpacity = 0.6,
    this.inactiveOpacityCurve = Curves.easeInOut,
    this.inactiveOpacityDuration = const Duration(milliseconds: 350),
    this.positionListener,
    this.clipBehavior = Clip.antiAlias,
  })  : animatedIconBuilder = _iconSizeBuilder<T>(
      iconBuilder, customIconBuilder, iconList, selectedIconScale),
        _iconArrangement = IconArrangement.row,
        super(
        values: values,
        styleBuilder: styleBuilder,
        customStyleBuilder: customStyleBuilder,
        styleList: styleList,
      );

  static AnimatedIconBuilder<T>? _iconSizeBuilder<T>(
      SimpleIconBuilder<T>? iconBuilder,
      AnimatedIconBuilder<T>? customIconBuilder,
      List<Widget>? iconList,
      double selectedIconScale) {
    assert(
    (iconBuilder ?? customIconBuilder) == null ||
        (iconBuilder ?? iconList) == null ||
        (customIconBuilder ?? iconList) == null,
    'Only one parameter from iconBuilder, customIconBuilder and iconList can be set.',
    );

    final AnimatedIconBuilder<T>? finalIconBuilder;
    if (iconBuilder != null) {
      finalIconBuilder = (c, l, g) => iconBuilder(l.value);
    } else if (iconList != null) {
      finalIconBuilder = (c, l, g) => iconList[l.index];
    } else {
      finalIconBuilder = customIconBuilder;
    }

    return finalIconBuilder == null
        ? null
        : (context, local, global) => Transform.scale(
      scale: 1.0 + local.animationValue * (selectedIconScale - 1.0),
      child: finalIconBuilder!(context, local, global),
    );
  }

  _BaseToggleStyle? _styleBuilder(BuildContext context,
      StyledToggleProperties<T> local, GlobalToggleProperties<T> global) {
    if (customStyleBuilder != null) {
      return customStyleBuilder!(context, local, global);
    }
    if (styleBuilder != null) {
      return styleBuilder!(local.value);
    }
    if (styleList != null) {
      if (local.index < 0) return null;
      return styleList![local.index];
    }
    return null;
  }

  // END OF CONSTRUCTOR SECTION

  BorderRadiusGeometry get indicatorBorderRadiusDifference =>
      BorderRadius.circular(borderWidth);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    BorderRadiusGeometry defaultBorderRadius =
    BorderRadius.circular(height / 2);
    final style = ToggleStyle._(
      indicatorColor: theme.colorScheme.secondary,
      indicatorGradient: null,
      backgroundColor: theme.colorScheme.surface,
      backgroundGradient: null,
      borderColor: theme.colorScheme.secondary,
      borderRadius: defaultBorderRadius,
      indicatorBorderRadius: null,
      indicatorBorder: null,
      indicatorBoxShadow: null,
      boxShadow: null,
    )._merge(this.style, indicatorBorderRadiusDifference);

    return CustomAnimatedToggleSwitch<T>(
        animationCurve: animationCurve,
        animationDuration: animationDuration,
        fittingMode: fittingMode,
        spacing: spacing,
        height: height,
        onTap: onTap,
        current: current,
        values: values,
        onChanged: onChanged,
        indicatorSize: indicatorSize,
        iconArrangement: _iconArrangement,
        iconsTappable: iconsTappable,
        cursors: cursors,
        minTouchTargetSize: minTouchTargetSize,
        textDirection: textDirection,
        allowUnlistedValues: allowUnlistedValues,
        indicatorAppearingBuilder: indicatorAppearingBuilder,
        indicatorAppearingDuration: indicatorAppearingDuration,
        indicatorAppearingCurve: indicatorAppearingCurve,
        positionListener: positionListener,
        separatorBuilder: customSeparatorBuilder ??
            (separatorBuilder == null
                ? null
                : (context, local, global) => separatorBuilder!(local.index)),
        backgroundIndicatorBuilder: /*foregroundIndicatorIconBuilder != null
            ? null
            :*/ (context, properties) =>
            _indicatorBuilder(context, properties, style),
        foregroundIndicatorBuilder: /*foregroundIndicatorIconBuilder == null
            ? null
            :*/ (context, properties) =>
            _indicatorBuilder(context, properties, style),
        iconBuilder: (context, local, global) => _animatedOpacityIcon(
            _animatedSizeIcon(context, local, global), local.value == current),
        padding: EdgeInsets.all(borderWidth),
        active: active,
        wrapperBuilder: (context, global, child) {
          return AnimatedOpacity(
            opacity: global.active ? 1.0 : inactiveOpacity,
            duration: inactiveOpacityDuration,
            curve: inactiveOpacityCurve,
            child: _animationTypeBuilder<_BaseToggleStyle>(
              context,
              styleAnimationType,
                  (local) => style._merge(
                _styleBuilder(context, local, global),
                indicatorBorderRadiusDifference,
              ),
              _BaseToggleStyle._lerpFunction(styleAnimationType),
                  (style) => DecoratedBox(
                decoration: BoxDecoration(
                  color: style._backgroundGradient != null
                      ? null
                      : style._backgroundColor?.value,
                  gradient: style._backgroundGradient?.value,
                  borderRadius: style._borderRadius?.value,
                  boxShadow: style._boxShadow?.value,
                ),
                child: DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    border: borderWidth <= 0.0 || style._borderColor == null
                        ? null
                        : Border.all(
                      color: style._borderColor!.value,
                      width: borderWidth,
                    ),
                    borderRadius: style._borderRadius?.value,
                  ),
                  child: ClipRRect(
                    clipBehavior: clipBehavior,
                    borderRadius:
                    style._borderRadius?.value ?? BorderRadius.zero,
                    child: child,
                  ),
                ),
              ),
              global,
            ),
          );
        });
  }

  Widget _animationTypeBuilder<V>(
      BuildContext context,
      AnimationType animationType,
      V Function(StyledToggleProperties<T> local) valueProvider,
      V Function(V value1, V value2, double t) lerp,
      Widget Function(V value) builder,
      GlobalToggleProperties<T> properties,
      ) {
    currentValueProvider() => valueProvider(
      StyledToggleProperties(
          value: current, index: values.indexOf(current)),
    );
    switch (animationType) {
      case AnimationType.none:
        return builder(currentValueProvider());
      case AnimationType.onSelected:
        V currentValue = currentValueProvider();
        return TweenAnimationBuilder<V>(
          curve: animationCurve,
          duration: animationDuration,
          tween: CustomTween(lerp, begin: currentValue, end: currentValue),
          builder: (context, value, _) => builder(value),
        );
      case AnimationType.onHover:
        return AnimationTypeHoverBuilder(
          valueProvider: valueProvider,
          lerp: lerp,
          builder: builder,
          properties: properties,
          animationDuration: animationDuration,
          animationCurve: animationCurve,
          indicatorAppearingDuration: indicatorAppearingDuration,
          indicatorAppearingCurve: indicatorAppearingCurve,
        );
    }
  }

  Widget _indicatorBuilder(BuildContext context,
      DetailedGlobalToggleProperties<T> properties, _BaseToggleStyle style) {
    final child = foregroundIndicatorIconBuilder?.call(context, properties);
    return _animationTypeBuilder<_BaseToggleStyle>(
      context,
      indicatorAnimationType,
          (local) => style._merge(
        _styleBuilder(context, local, properties),
        indicatorBorderRadiusDifference,
      ),
      _BaseToggleStyle._lerpFunction(indicatorAnimationType),
          (style) => _customIndicatorBuilder(context, style, child, properties),
      properties,
    );
  }

  Widget _animatedIcon(BuildContext context, AnimatedToggleProperties<T> local,
      DetailedGlobalToggleProperties<T> global) {
    return Opacity(
      opacity: 1.0 - global.loadingAnimationValue.clamp(0.0, 1.0),
      child: Center(child: animatedIconBuilder!(context, local, global)),
    );
  }

  Widget _animatedSizeIcon(BuildContext context, LocalToggleProperties<T> local,
      DetailedGlobalToggleProperties<T> global) {
    if (animatedIconBuilder == null) return const SizedBox();
    switch (iconAnimationType) {
      case AnimationType.none:
        return _animatedIcon(
          context,
          AnimatedToggleProperties.fromLocal(
            animationValue: local.value == global.current ? 1.0 : 0.0,
            properties: local,
          ),
          global,
        );
      case AnimationType.onSelected:
        double currentTweenValue = local.value == global.current ? 1.0 : 0.0;
        return TweenAnimationBuilder<double>(
          curve: iconAnimationCurve,
          duration: iconAnimationDuration ?? animationDuration,
          tween:
          Tween<double>(begin: currentTweenValue, end: currentTweenValue),
          builder: (c, value, child) {
            return _animatedIcon(
              c,
              AnimatedToggleProperties.fromLocal(
                animationValue: value,
                properties: local,
              ),
              global,
            );
          },
        );
      case AnimationType.onHover:
        double animationValue = 0.0;
        double localPosition =
            global.position - global.position.floorToDouble();
        if (values[global.position.floor()] == local.value) {
          animationValue = 1.0 - localPosition;
        } else if (values[global.position.ceil()] == local.value) {
          animationValue = localPosition;
        }
        return _animatedIcon(
          context,
          AnimatedToggleProperties.fromLocal(
            animationValue: animationValue,
            properties: local,
          ),
          global,
        );
    }
  }

  Widget _animatedOpacityIcon(Widget icon, bool active) {
    return iconOpacity >= 1.0 && selectedIconOpacity >= 1.0
        ? icon
        : AnimatedOpacity(
      opacity: active ? selectedIconOpacity : iconOpacity,
      duration: animationDuration,
      child: icon,
    );
  }

  Widget _customIndicatorBuilder(BuildContext context, _BaseToggleStyle style,
      Widget? child, DetailedGlobalToggleProperties<T> global) {
    final loadingValue = global.loadingAnimationValue.clamp(0.0, 1.0);
    return DecoratedBox(
        key: AnimatedToggleSwitchTestKeys.indicatorDecoratedBoxKey,
        decoration: BoxDecoration(
          color: style._indicatorGradient != null
              ? null
              : style._indicatorColor?.value,
          gradient: style._indicatorGradient?.value,
          borderRadius: style._indicatorBorderRadius?.value,
          border: style._indicatorBorder?.value,
          boxShadow: style._indicatorBoxShadow?.value,
        ),
        child: Center(
          child: Stack(
            fit: StackFit.passthrough,
            alignment: Alignment.center,
            children: [
              if (loadingValue < 1.0)
                Opacity(
                    key: const ValueKey(0),
                    opacity: 1.0 - loadingValue,
                    child: child),
            ],
          ),
        ));
  }
}


extension _XTargetPlatform on TargetPlatform {
  bool get isApple =>
      this == TargetPlatform.iOS || this == TargetPlatform.macOS;
}

extension _XColorToGradient on Color {
  Gradient toGradient() => LinearGradient(colors: [this, this]);
}