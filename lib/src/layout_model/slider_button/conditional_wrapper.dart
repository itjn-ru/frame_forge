import 'package:flutter/material.dart';

class _ConditionalWrapper extends StatefulWidget {
  final Widget Function(BuildContext context, Widget child) wrapper;
  final bool condition;
  final Widget child;

  const _ConditionalWrapper({
    required this.wrapper,
    required this.condition,
    required this.child,
  });

  @override
  State<_ConditionalWrapper> createState() => _ConditionalWrapperState();
}

class _ConditionalWrapperState extends State<_ConditionalWrapper> {
  final _childKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final child = EmptyWidget(key: _childKey, child: widget.child);
    if (widget.condition) return widget.wrapper(context, child);
    return child;
  }
}

//ignore: unused_element
class _ConditionalOpacity extends StatelessWidget {
  final double opacity;
  final Widget Function(BuildContext context) builder;

  const _ConditionalOpacity({required this.opacity, required this.builder});

  @override
  Widget build(BuildContext context) {
    return _ConditionalWrapper(
      wrapper: (context, child) => Opacity(
        opacity: opacity,
        child: builder(context),
      ),
      condition: opacity > 0.0,
      child: const SizedBox(),
    );
  }
}

// coverage:ignore-end

class EmptyWidget extends StatelessWidget {
  final Widget child;

  const EmptyWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}