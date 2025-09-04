import 'package:flutter/material.dart';

class CustomTween<V> extends Tween<V> {
  final V Function(V value1, V value2, double t) lerpFunction;

  CustomTween(this.lerpFunction, {super.begin, super.end});

  @override
  V lerp(double t) => lerpFunction(begin as V, end as V, t);
}
