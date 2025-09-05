// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CustomMargin {
  final List<int> margin;
  const CustomMargin(this.margin);

  int left() => margin[0];
  int top() => margin[1];
  int right() => margin[2];
  int bottom() => margin[3];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'margin': margin};
  }

  factory CustomMargin.fromMap(Map<String, dynamic> map) {
    return CustomMargin(List<int>.from((map['margin'] as List<int>)));
  }

  String toJson() => json.encode(toMap());

  factory CustomMargin.fromJson(String source) =>
      CustomMargin.fromMap(json.decode(source) as Map<String, dynamic>);
}
