import 'package:uuid/uuid.dart';

import 'from_map_to_map_mixin.dart';
import 'property.dart';
import 'style.dart';

/// Base class for all layout elements in Frame Forge.
///
/// [Item] represents any element that can be part of a layout hierarchy,
/// including components, pages, groups, and data sources. Each item has
/// properties, child items, and can be serialized to/from maps.
class Item with FromMapToMap {
  /// Whether this item can contain child items.
  bool mayBeParent;

  /// The type identifier for this item (e.g., 'component', 'page', 'group').
  String type;

  /// Optional unique identifier for the item.
  String? itemId;

  /// Child items contained within this item.
  List<Item> items = <Item>[];

  /// Properties defining the item's configuration and appearance.
  Map<String, Property> properties = <String, Property>{};

  /// Creates a new item with the specified [type] and [name].
  ///
  /// - [mayBeParent]: Whether this item can contain children (defaults to false)
  Item(this.type, name, {this.mayBeParent = false}) {
    properties['id'] = Property('Id', itemId ?? const Uuid().v4());
    properties['name'] = Property('Name', name);
    properties['style'] = Property('Style', Style.basic, type: Style);
  }

  /// Accesses a property value by [name].
  ///
  /// Returns the value of the property with the given name, or null if not found.
  dynamic operator [](String name) {
    return properties[name]?.value;
  }

  /// Gets the unique identifier for this item.
  String get id => properties['id']?.value ?? '';

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};

    map['layout'] = <String, Object>{
      'properties': propertiesToMap(this),
      'items': itemsToMap(this),
      'type': type,
      'mayBeParent': mayBeParent,
    };

    return map['layout'];
  }

  Item fromMap(Map map) {
    final Item item = Item(
      map['type'],
      map['properties']['name'],
      mayBeParent: map['mayBeParent'] as bool,
    );
    item
      ..properties = propertiesFromMap(map['properties'])
      ..items = itemsFromMap(item, map['items']);

    return item;
  }

  Item copyWith({
    bool? mayBeParent,
    String? type,
    String? id,
    List<Item>? items,
    Map<String, Property>? properties,
  }) {
    final Item item = Item(
      type ?? this.type,
      (properties ?? this.properties)['name'],
      mayBeParent: mayBeParent ?? this.mayBeParent,
    );
    item
      ..properties = properties ?? this.properties
      ..items = items ?? this.items;
    item.properties['id']?.value = id ?? itemId;
    return item;
  }
}
