import 'form_checkbox.dart';
import 'form_radio.dart';
import 'form_slider_button.dart';
import 'form_text_field.dart';
import 'item.dart';
import 'layout_component_source.dart';

/// An unfilled required input field of a layout.
class MissingRequiredField {
  /// Index of the layout page (`ComponentPage`) holding the field.
  final int pageIndex;

  /// Page name (the `name` property).
  final String pageName;

  /// Human-readable field label: caption, then text, then source.
  final String label;

  /// Stable source key of the field (see [fieldKey]).
  final String key;

  const MissingRequiredField({
    required this.pageIndex,
    required this.pageName,
    required this.label,
    required this.key,
  });
}

/// Predicate deciding whether a component's bound value counts as
/// filled. Hosts can override the default rule, e.g. to require at
/// least two words for full-name fields.
typedef FieldValueFillPredicate =
    bool Function(Item item, Map<String, dynamic>? json);

/// Component types that support the required flag
/// (`<required>true</required>` in the layout file).
bool _isRequiredCapable(Item item) =>
    item is FormTextField ||
    item is FormRadio ||
    item is FormCheckbox ||
    item is FormSliderButton;

/// Whether the component is marked as a required input field.
bool isRequiredField(Item item) =>
    _isRequiredCapable(item) && item['required'] == true;

/// Stable key of a field within one layout: its source binding string.
/// Used to remember which fields are flagged as unfilled.
String fieldKey(Item item) => item.sourceSignature?.toString() ?? '';

/// Human-readable field name for user-facing messages.
String fieldLabel(Item item) {
  final String caption = item['caption']?.toString().trim() ?? '';
  if (caption.isNotEmpty) return caption;
  final String text = item['text']?.toString().trim() ?? '';
  if (text.isNotEmpty) return text;
  return item['source']?.toString() ?? fieldKey(item);
}

/// Default fill rule: a missing or blank value counts as unfilled.
bool isFieldValueFilled(Item item, Map<String, dynamic>? json) {
  final dynamic value = item.readSourceValue(json);
  if (value == null) return false;
  return value.toString().trim().isNotEmpty;
}

/// Collects every unfilled required field of a layout.
///
/// [pages] are the layout pages
/// (`root.items.whereType<ComponentPage>()`). When [onlyPageIndex] is
/// given, only that page is checked — used when leaving a page so its
/// empty required fields can be highlighted on return.
///
/// [isFilled] overrides the default fill rule (see
/// [isFieldValueFilled]); pass a host-specific predicate to enforce
/// domain rules such as "full name needs at least two words".
List<MissingRequiredField> collectMissingRequiredFields({
  required List<Item> pages,
  required Map<String, dynamic>? json,
  int? onlyPageIndex,
  FieldValueFillPredicate? isFilled,
}) {
  final FieldValueFillPredicate filled = isFilled ?? isFieldValueFilled;
  final out = <MissingRequiredField>[];
  for (int i = 0; i < pages.length; i++) {
    if (onlyPageIndex != null && i != onlyPageIndex) continue;
    final Item page = pages[i];
    _collectFromItems(
      items: page.items,
      json: json,
      pageIndex: i,
      pageName: page['name']?.toString() ?? 'Page ${i + 1}',
      out: out,
      isFilled: filled,
    );
  }
  return out;
}

bool _isMissing(
  Item item,
  Map<String, dynamic>? json,
  FieldValueFillPredicate isFilled,
) => isRequiredField(item) && item.hasSource && !isFilled(item, json);

void _collectFromItems({
  required List<Item> items,
  required Map<String, dynamic>? json,
  required int pageIndex,
  required String pageName,
  required List<MissingRequiredField> out,
  required FieldValueFillPredicate isFilled,
}) {
  for (final Item child in items) {
    if (_isMissing(child, json, isFilled)) {
      out.add(
        MissingRequiredField(
          pageIndex: pageIndex,
          pageName: pageName,
          label: fieldLabel(child),
          key: fieldKey(child),
        ),
      );
    }
    if (child.items.isNotEmpty) {
      _collectFromItems(
        items: child.items,
        json: json,
        pageIndex: pageIndex,
        pageName: pageName,
        out: out,
        isFilled: isFilled,
      );
    }
  }
}
