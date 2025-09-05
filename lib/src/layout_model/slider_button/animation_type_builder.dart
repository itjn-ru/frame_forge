import 'package:flutter/material.dart';
import 'conditional_wrapper.dart';
import 'properties.dart';
import 'tweens.dart';

class AnimationTypeHoverBuilder<T, V> extends StatefulWidget {
  final V Function(StyledToggleProperties<T> local) valueProvider;
  final V Function(V value1, V value2, double t) lerp;
  final Widget Function(V value) builder;
  final GlobalToggleProperties<T> properties;
  final Duration animationDuration;
  final Curve animationCurve;
  final Duration indicatorAppearingDuration;
  final Curve indicatorAppearingCurve;
  final bool animateExternalChanges;

  const AnimationTypeHoverBuilder({
    super.key,
    required this.valueProvider,
    required this.lerp,
    required this.builder,
    required this.properties,
    required this.animationDuration,
    required this.animationCurve,
    required this.indicatorAppearingDuration,
    required this.indicatorAppearingCurve,
    this.animateExternalChanges = true,
  });

  @override
  State<AnimationTypeHoverBuilder<T, V>> createState() =>
      _AnimationTypeHoverBuilderState();
}

class _AnimationTypeHoverBuilderState<T, V>
    extends State<AnimationTypeHoverBuilder<T, V>> {
  final _builderKey = GlobalKey();
  T? _lastUnlistedValue;

  @override
  void initState() {
    super.initState();
    if (!widget.properties.isCurrentListed) {
      _lastUnlistedValue = widget.properties.current;
    }
  }

  @override
  void didUpdateWidget(covariant AnimationTypeHoverBuilder<T, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.properties.isCurrentListed) {
      _lastUnlistedValue = widget.properties.current;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pos = widget.properties.position;
    final values = widget.properties.values;
    final index1 = pos.floor();
    final index2 = pos.ceil();
    V listedValueFunction() => widget.lerp(
      widget.valueProvider(
        StyledToggleProperties(value: values[index1], index: index1),
      ),
      widget.valueProvider(
        StyledToggleProperties(value: values[index2], index: index2),
      ),
      pos - pos.floor(),
    );
    final indicatorAppearingAnimation =
        widget.properties.indicatorAppearingAnimation;
    return AnimatedBuilder(
      animation: indicatorAppearingAnimation,
      builder: (context, _) {
        final appearingValue = indicatorAppearingAnimation.value;
        if (appearingValue >= 1.0) {
          return EmptyWidget(
            key: _builderKey,
            child: widget.builder(listedValueFunction()),
          );
        }
        final unlistedValue = widget.valueProvider(
          StyledToggleProperties(value: _lastUnlistedValue as T, index: -1),
        );
        return TweenAnimationBuilder<V>(
          duration: widget.animationDuration,
          curve: widget.animationCurve,
          tween: CustomTween(
            widget.lerp,
            begin: unlistedValue,
            end: unlistedValue,
          ),
          builder: (context, unlistedValue, _) {
            return EmptyWidget(
              key: _builderKey,
              child: widget.builder(
                appearingValue <= 0.0
                    ? unlistedValue
                    : widget.lerp(
                        unlistedValue,
                        listedValueFunction(),
                        appearingValue,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
