import 'dart:convert';

import 'package:flutter/widgets.dart';

enum CustomBorderRadiusEnum {
  none(BorderRadiusNone(), 'Нет радиуса'),
  all(BorderRadiusAll(0), 'Все углы'),
  top(BorderRadiusTop(0), 'Только верхние'),
  bottom(BorderRadiusBottom(0), 'Только нижние');

  final CustomBorderRadius type;
  final String title;
  const CustomBorderRadiusEnum(this.type, this.title);

  static CustomBorderRadiusEnum fromModel(dynamic borderRadius) {
    if (borderRadius == null) return none;
    switch (borderRadius as CustomBorderRadius) {
      case BorderRadiusNone():
        return none;
      case BorderRadiusAll():
        return all;
      case BorderRadiusTop():
        return top;
      case BorderRadiusBottom():
        return bottom;
    }
  }
}

sealed class CustomBorderRadius {
  const CustomBorderRadius();
  BorderRadius borderRadius(double scale);

  factory CustomBorderRadius.fromJson(Map<String, dynamic> json) {
    final discriminator = json['type'] as String;

    switch (discriminator) {
      case 'BorderRadiusNone':
        return BorderRadiusNone.fromJson(json);
      case 'BorderRadiusAll':
        return BorderRadiusAll.fromJson(json);
      case 'BorderRadiusTop':
        return BorderRadiusTop.fromJson(json);
      case 'BorderRadiusBottom':
        return BorderRadiusBottom.fromJson(json);
      default:
        throw Exception('Unknown class: $discriminator');
    }
  }
  static Map<String, dynamic> toJson(CustomBorderRadius obj) {
    switch (obj) {
      case BorderRadiusNone():
        return {'type': 'BorderRadiusNone'};
      case BorderRadiusAll():
        return {'type': 'BorderRadiusAll', 'radius': obj.toJson()};
      case BorderRadiusTop():
        return {'type': 'BorderRadiusTop', 'radius': jsonEncode(obj.toJson())};
      case BorderRadiusBottom():
        return {'type': 'BorderRadiusBottom', 'radius': obj.toJson()};
    }
  }
}

class BorderRadiusNone extends CustomBorderRadius {
  const BorderRadiusNone();

  @override
  BorderRadius borderRadius(double scale) => BorderRadius.zero;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'type': 'BorderRadiusNone'};
  }

  factory BorderRadiusNone.fromJson(Map<String, dynamic> map) {
    return const BorderRadiusNone();
  }
}

class BorderRadiusAll extends CustomBorderRadius {
  final double radius;
  const BorderRadiusAll(this.radius);

  @override
  BorderRadius borderRadius(double scale) =>
      BorderRadius.all(Radius.circular(radius / scale));

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'radius': radius, 'type': 'BorderRadiusAll'};
  }

  factory BorderRadiusAll.fromJson(Map<String, dynamic> map) {
    return BorderRadiusAll(double.tryParse(map['radius'].toString()) ?? 0);
  }
}

class BorderRadiusTop extends CustomBorderRadius {
  final double radius;
  const BorderRadiusTop(this.radius);

  @override
  BorderRadius borderRadius(double scale) => BorderRadius.only(
    topLeft: Radius.circular(radius / scale),
    topRight: Radius.circular(radius / scale),
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'radius': radius, 'type': 'BorderRadiusTop'};
  }

  factory BorderRadiusTop.fromJson(Map<String, dynamic> map) {
    return BorderRadiusTop(double.tryParse(map['radius'].toString()) ?? 0);
  }
}

class BorderRadiusBottom extends CustomBorderRadius {
  final double radius;
  const BorderRadiusBottom(this.radius);

  @override
  BorderRadius borderRadius(double scale) => BorderRadius.only(
    bottomLeft: Radius.circular(radius / scale),
    bottomRight: Radius.circular(radius / scale),
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'radius': radius, 'type': 'BorderRadiusBottom'};
  }

  factory BorderRadiusBottom.fromJson(Map<String, dynamic> map) {
    return BorderRadiusBottom(double.tryParse(map['radius'].toString()) ?? 0);
  }
}
