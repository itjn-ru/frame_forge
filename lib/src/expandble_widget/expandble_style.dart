import 'package:flutter/material.dart';

class ExpandableStyle {
  final Duration animationDuration;
  final Curve animationCurve;
  final EdgeInsetsGeometry buttonPadding;
  final EdgeInsetsGeometry contentPadding;
  final TextStyle buttonTextStyle;
  final Color buttonIconColor;
  final Color buttonColor;
  final BorderRadius buttonBorderRadius;
  final BoxDecoration? contentDecoration;

  /// Отступ(расстояние) списка от заголовка
  final double marginTop;
  
final Widget? title;
  const ExpandableStyle({
    this.title = const Text('Развернуть'),
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.buttonPadding = const EdgeInsets.all(6),
    this.contentPadding = const EdgeInsets.all(11),
    this.buttonTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    this.marginTop=0.0,
    this.buttonIconColor = Colors.black,
    this.buttonColor = Colors.transparent,
    this.buttonBorderRadius = BorderRadius.zero,
    this.contentDecoration,
  });

  ExpandableStyle copyWith({
    Duration? animationDuration,
    Curve? animationCurve,
    EdgeInsetsGeometry? buttonPadding,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? buttonTextStyle,
    Color? buttonIconColor,
    Color? buttonColor,
    BorderRadius? buttonBorderRadius,
    BoxDecoration? contentDecoration,
    Widget? title,
  }) {
    return ExpandableStyle(
      title: title ?? this.title,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      buttonPadding: buttonPadding ?? this.buttonPadding,
      contentPadding: contentPadding ?? this.contentPadding,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      buttonIconColor: buttonIconColor ?? this.buttonIconColor,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      contentDecoration: contentDecoration ?? this.contentDecoration,
    );
  }
}