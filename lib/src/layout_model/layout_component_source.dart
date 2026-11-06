import 'item.dart';
import 'source_reference.dart';

/// Resolves a component's bound data location in a checklist-like
/// document, preferring the typed `SourceReference` scheme (`sourceV2`)
/// over the legacy flat string `source` key when a variable reference
/// is configured.
extension LayoutComponentSource on Item {
  SourceReference? get _sourceReference {
    final dynamic value = properties['sourceV2']?.value;
    if (value is SourceReference && value.isNotEmpty) return value;
    return null;
  }

  /// A value that changes whenever the effective source binding changes,
  /// suitable for `didUpdateWidget` comparisons.
  Object? get sourceSignature => _sourceReference?.toString() ?? this['source'];

  /// Whether this component has a source configured, via either scheme.
  bool get hasSource =>
      _sourceReference != null ||
      (this['source']?.toString().isNotEmpty ?? false);

  /// Reads the value bound to this component's source from [json].
  dynamic readSourceValue(Map<String, dynamic>? json) {
    if (json == null) return null;
    final SourceReference? ref = _sourceReference;
    if (ref == null) return json[this['source']];
    if (ref.mapKey.isEmpty) return json[ref.variableName];
    final dynamic nested = json[ref.variableName];
    return nested is Map ? nested[ref.mapKey] : null;
  }

  /// Writes [value] to the location bound by this component's source,
  /// creating an intermediate map for `variableName.mapKey` references
  /// if it does not already exist.
  void writeSourceValue(Map<String, dynamic>? json, dynamic value) {
    if (json == null) return;
    final SourceReference? ref = _sourceReference;
    if (ref == null) {
      json[this['source']] = value;
      return;
    }
    if (ref.mapKey.isEmpty) {
      json[ref.variableName] = value;
      return;
    }
    final Map<String, dynamic> nested = json[ref.variableName] is Map
        ? Map<String, dynamic>.from(json[ref.variableName] as Map)
        : <String, dynamic>{};
    nested[ref.mapKey] = value;
    json[ref.variableName] = nested;
  }
}
