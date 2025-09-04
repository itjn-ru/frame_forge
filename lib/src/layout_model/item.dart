import 'package:uuid/uuid.dart';

import 'from_map_to_map_mixin.dart';
import 'property.dart';
import 'style.dart';

class Item with FromMapToMap {
   bool mayBeParent;
   String type;
  String? itemId;
  List<Item> items = <Item>[];
  Map<String, Property> properties = {};

  Item(this.type, name, {this.mayBeParent = false}) {
    properties['id'] = Property('идентификатор', itemId ?? const Uuid().v4());
    properties['name'] = Property('имя', name);
    properties['style'] = Property('стиль', Style.basic, type: Style);
  }

  dynamic operator [](String name) {
    return properties[name]?.value;
  }

  String get id => properties['id']?.value ?? '';

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};

    map['layout'] = {
      'properties': propertiesToMap(this),
      'items': itemsToMap(this),
      'type': type,
      'mayBeParent': mayBeParent,
    };

    return map['layout'];
  }

  Item fromMap(Map map) {
    final item = Item(map['type'], map['properties']['name'],
        mayBeParent: map['mayBeParent'] as bool);
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
    final item = Item(
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

