import 'dart:async';

import 'package:flutter/material.dart';

import 'expandble_style.dart';
import 'expandble_widget_controller.dart';

class ExpandableWidget extends StatelessWidget {
  final Widget child;
  final ExpandableController? controller;
  final ExpandableStyle style;

  const ExpandableWidget({
    super.key,
    required this.child,
    this.controller,
    this.style = const ExpandableStyle(),
  });

  @override
  Widget build(BuildContext context) {
    return _ExpandableWidgetContent(
      controller: controller ?? ExpandableControllerImpl(),
      style: style,
      child: child,
    );
  }
}

class _ExpandableWidgetContent extends StatefulWidget {
  final ExpandableController controller;
  final ExpandableStyle style;
  final Widget child;
  const _ExpandableWidgetContent({
    required this.controller,
    required this.style,
    required this.child,
  });

  @override
  State<_ExpandableWidgetContent> createState() =>
      _ExpandableWidgetContentState();
}

class _ExpandableWidgetContentState extends State<_ExpandableWidgetContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late StreamSubscription<bool> _stateSubscription;
  final GlobalKey _contentKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.style.animationDuration,
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.style.animationCurve,
    ));

    _stateSubscription = widget.controller.stateChanges.listen((isExpanded) {
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _contentKey.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox;
        widget.controller.updateHeight(renderBox.size.height);
      }
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToggleButton(),
        _buildContent(),
      ],
    );
  }

  Widget _buildToggleButton() {
    return Material(
      color: widget.style.buttonColor,
      borderRadius: widget.style.buttonBorderRadius,
      child: InkWell(
        onTap: widget.controller.toggle,
        borderRadius: widget.style.buttonBorderRadius,
        child: Stack(
          children: [
            widget.style.title!,
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: widget.style.buttonPadding,
                child: RotationTransition(
                  turns:
                      Tween(begin: 0.0, end: 0.5).animate(_animationController),
                  child: Icon(
                    Icons.expand_more,
                    color: widget.style.buttonIconColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            heightFactor: _heightAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
          margin: EdgeInsets.only(top: widget.style.marginTop),
          key: _contentKey,
          padding: widget.style.contentPadding,
          decoration: widget.style.contentDecoration,
          child: widget.child),
    );
  }
}
