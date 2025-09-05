import 'package:flutter/material.dart';
import 'property.dart';
import 'root.dart';
import 'style.dart';
import 'package:xml/xml.dart';

import 'item.dart';

/// Saves a layout model map to XML format
/// 
/// Converts the layout model's map representation into a well-formatted
/// XML string that can be saved to a file or transmitted over a network.
/// 
/// [root] The layout model map to convert to XML
/// 
/// Returns a formatted XML string representation of the layout model.
String saveMap(Map root) {
  final builder = XmlBuilder();
  builder.processing("xml", "version=\"1.0\" encoding=\"UTF-8\"");

  builder.element(
    "layout",
    nest: () {
      _saveMapProperties(builder, root['properties']);
      _saveMapItems(builder, root['items']);
    },
  );

  final document = builder.buildDocument();
  return document.toXmlString(pretty: true);
}

/// Saves properties section to XML builder
/// 
/// [builder] The XML builder to append properties to
/// [properties] The properties map to serialize
_saveMapProperties(XmlBuilder builder, Map properties) {
  builder.element(
    "properties",
    nest: () {
      properties.forEach((key, property) {
        builder.element(
          key,
          nest: () {
            if (property is Map) {
              property.forEach((key, value) {
                builder.attribute(key, value);
              });
            } else {
              builder.text(property.toString().replaceAll(' ', '&#x20;'));
              // builder.text(property.toString());
            }
          },
        );
      });
    },
  );
}

/// Saves items section to XML builder
/// 
/// [builder] The XML builder to append items to
/// [items] The items list to serialize
_saveMapItems(XmlBuilder builder, List items) {
  builder.element(
    "items",
    nest: () {
      for (final element in items) {
        builder.element(
          element['type'],
          nest: () {
            _saveMapProperties(builder, element['properties']);
            _saveMapItems(builder, element['items']);
          },
        );
      }
    },
  );
}

/// Reads a layout model from XML format
/// 
/// Parses an XML string representation of a layout model and converts
/// it back into the internal map format used by the layout system.
/// 
/// [layout] The XML string to parse
/// 
/// Returns a map representation of the layout model.
Map<String, dynamic> readMap(String layout) {
  final xml = XmlDocument.parse(layout);
  final xmlRoot = xml.rootElement;

  final Map<String, dynamic> root = {};
  root['properties'] = _readMapProperties(xmlRoot.getElement("properties"));
  root['items'] = _readMapItems(xmlRoot.getElement("items"));

  return root;
}

/// Reads properties section from XML element
/// 
/// [xmlProperties] The XML element containing properties to parse
/// 
/// Returns a map of property names to their values.
Map _readMapProperties(XmlElement? xmlProperties) {
  final Map properties = {};

  if (xmlProperties == null) {
    return properties;
  }

  if (xmlProperties.childElements.isEmpty) {
    return properties;
  }

  for (final XmlElement xmlProperty in xmlProperties.childElements) {
    final xmlValue = xmlProperty.children;
    final propertyKey = xmlProperty.localName;
    dynamic propertyValue;

    if (xmlProperty.attributes.isNotEmpty) {
      propertyValue = {
        for (final attribute in xmlProperty.attributes)
          attribute.localName: attribute.value,
      };
    } else if (xmlValue.isNotEmpty) {
      propertyValue = xmlValue.single.value;
    }

    properties[propertyKey] = propertyValue.runtimeType == String
        ? propertyValue.toString().replaceAll('&#x20;', ' ')
        : propertyValue ?? "";

    /*if (xmlProperty.childElements.isEmpty) {
      json[propertyKey] =
          xmlPropertyValue.isEmpty ? null : xmlPropertyValue.single.value;
    } else {
      List list = [];

      for (var entry in xmlProperty.childElements) {
        list.add({entry.localName: entry.children.single.value});
      }

      json[propertyKey] = list;
    }*/
  }

  return properties;
}

List _readMapItems(XmlElement? xmlItems) {
  final List items = [];

  if (xmlItems == null) {
    return items;
  }

  if (xmlItems.childElements.isEmpty) {
    return items;
  }

  for (final XmlElement xmlItem in xmlItems.childElements) {
    final item = {
      'type': xmlItem.localName,
      'properties': _readMapProperties(xmlItem.getElement("properties")),
      'items': _readMapItems(xmlItem.getElement("items")),
    };
    items.add(item);
  }

  return items;
}

String save(Root root) {
  final builder = XmlBuilder();
  builder.processing("xml", "version=\"1.0\" encoding=\"UTF-8\"");

  builder.element(
    "layout",
    nest: () {
      _saveProperties(builder, root.properties);
      _saveItems(builder, root.items);
    },
  );

  final document = builder.buildDocument();

  return document.toXmlString(pretty: true);
}

_saveProperties(XmlBuilder builder, Map<String, Property> properties) {
  builder.element(
    "properties",
    nest: () {
      properties.forEach((key, property) {
        builder.element(
          key,
          nest: () {
            switch (property.type) {
              case const (Offset):
                builder.attribute("left", (property.value as Offset).dx);
                builder.attribute("top", (property.value as Offset).dy);
                break;
              case const (Size):
                builder.attribute("width", (property.value as Size).width);
                builder.attribute("height", (property.value as Size).height);
                break;
              case const (Color):
                builder.text(
                  property.value.value.toRadixString(16).toUpperCase(),
                );
                break;
              case const (TextStyle):
                builder.attribute("fontSize", property.value.fontSize);
                break;
              case const (CustomBorderStyle):
                builder.attribute("borderWidth", property.value.width);
                builder.attribute(
                  "borderColor",
                  property.value.color.value.toRadixString(16).toUpperCase(),
                );
                builder.attribute("borderSide", property.value.side);
                break;
              //case XFile:
              //  builder.cdata(base64Encode(property.value));
              default:
                builder.text(property.value.toString());
            }
          },
        );
      });
    },
  );
}

_saveItems(XmlBuilder builder, List<Item> items) {
  builder.element(
    "items",
    nest: () {
      for (final element in items) {
        builder.element(
          element.type,
          nest: () {
            _saveProperties(builder, element.properties);
            _saveItems(builder, element.items);
          },
        );
      }
    },
  );
}

Root read(String layout) {
  final xml = XmlDocument.parse(layout);
  final xmlRoot = xml.rootElement;

  final properties = _readProperties(xmlRoot.getElement("properties"));

  final Root root = Root(properties["name"]);
  root.properties = properties;

  root.items = _readItems(xmlRoot.getElement("items"));

  /*

  List<LayoutComponent> components = [];
  List<LayoutSource> sources = [];

  var xmlPages = root.findElements("componentPage");
  xmlPages.toList().addAll(root.findElements("sourcePage"));


  var xmlElements = xmlSources.toList();
  xmlElements.addAll(root.findElements("component"));

  for (XmlElement xmlElement in xmlElements) {
    var xmlProperties = xmlElement.getElement("properties");
    var xmlItems = xmlElement.getElement("items");

    Map properties = _readProperties(xmlProperties);
    Map items = _readItems(xmlItems);

    var xmlType = xmlElement.getAttribute("type") ?? "";

    if (xmlElement.name.local == "source") {
      SourceType type = SourceType.values.firstWhere((e) => e.name == xmlType,
          orElse: () => SourceType.values.first);
      LayoutSource source =
          LayoutSource.createFromJson(type, properties, items);
      sources.add(source);
    } else if (xmlElement.name.local == "component") {
      ComponentType type = ComponentType.values.firstWhere(
          (e) => e.name == xmlType,
          orElse: () => ComponentType.values.first);
      LayoutComponent component =
          LayoutComponent.createFromJson(type, properties, items);
      components.add(component);
    }
  }

  return {"components": components, "sources": sources};*

   */

  return root;
}

Map<String, Property> _readProperties(XmlElement? xmlProperties) {
  final Map<String, Property> properties = {};

  if (xmlProperties == null) {
    return properties;
  }

  if (xmlProperties.childElements.isEmpty) {
    return properties;
  }

  for (final XmlElement xmlProperty in xmlProperties.childElements) {
    final xmlValue = xmlProperty.children;
    final propertyKey = xmlProperty.localName;
    dynamic propertyValue;

    switch (propertyKey) {
      case "topBorder":
        propertyValue = CustomBorderStyle(
          double.tryParse(
                xmlProperty.attributes
                    .where((attribute) => attribute.name.local == "width")
                    .single
                    .value,
              ) ??
              0.0,
          Colors.black,
          xmlProperty.attributes
                  .where((attribute) => attribute.name.local == "side")
                  .single
                  .value
              as CustomBorderSide,
        );
        break;
      case "leftBorder":
        propertyValue = CustomBorderStyle(
          double.tryParse(
                xmlProperty.attributes
                    .where((attribute) => attribute.name.local == "width")
                    .single
                    .value,
              ) ??
              0.0,
          Colors.black,
          xmlProperty.attributes
                  .where((attribute) => attribute.name.local == "side")
                  .single
                  .value
              as CustomBorderSide,
        );
        break;
      case "rightBorder":
        propertyValue = CustomBorderStyle(
          double.tryParse(
                xmlProperty.attributes
                    .where((attribute) => attribute.name.local == "width")
                    .single
                    .value,
              ) ??
              0.0,
          Colors.black,
          xmlProperty.attributes
                  .where((attribute) => attribute.name.local == "side")
                  .single
                  .value
              as CustomBorderSide,
        );
        break;
      case "bottomBorder":
        propertyValue = CustomBorderStyle(
          double.tryParse(
                xmlProperty.attributes
                    .where((attribute) => attribute.name.local == "width")
                    .single
                    .value,
              ) ??
              0.0,
          Colors.black,
          xmlProperty.attributes
                  .where((attribute) => attribute.name.local == "side")
                  .single
                  .value
              as CustomBorderSide,
        );
        break;
      case "position":
        propertyValue = Offset(
          double.tryParse(
                xmlProperty.attributes
                    .where((attribute) => attribute.name.local == "left")
                    .single
                    .value,
              ) ??
              0.0,
          double.tryParse(
                xmlProperty.attributes
                    .where((attribute) => attribute.name.local == "top")
                    .single
                    .value,
              ) ??
              0.0,
        );
        break;
      case "size":
        propertyValue = Size(
          double.tryParse(
                xmlProperty.attributes
                    .where((attribute) => attribute.name.local == "width")
                    .single
                    .value,
              ) ??
              0.0,
          double.tryParse(
                xmlProperty.attributes
                    .where((attribute) => attribute.name.local == "height")
                    .single
                    .value,
              ) ??
              0.0,
        );
        break;
      case "color":
        break;
      default:
        if (xmlValue.isNotEmpty) {
          propertyValue = xmlValue.single.value;
        }
    }

    if (propertyValue != null) {
      properties[propertyKey] = Property(
        propertyKey,
        propertyValue,
        type: propertyValue.runtimeType,
      );
    }

    /*if (xmlProperty.childElements.isEmpty) {
      json[propertyKey] =
          xmlPropertyValue.isEmpty ? null : xmlPropertyValue.single.value;
    } else {
      List list = [];

      for (var entry in xmlProperty.childElements) {
        list.add({entry.localName: entry.children.single.value});
      }

      json[propertyKey] = list;
    }*/
  }

  return properties;
}

List<Item> _readItems(XmlElement? xmlItems) {
  final List<Item> items = <Item>[];

  if (xmlItems == null) {
    return items;
  }

  if (xmlItems.childElements.isEmpty) {
    return items;
  }

  for (final XmlElement xmlItem in xmlItems.childElements) {
    final properties = _readProperties(xmlItem.getElement("properties"));
    final Item item = Item("item", properties["name"]);
    item.properties = properties;
    item.items = _readItems(xmlItem.getElement("items"));
    items.add(item);
  }

  return items;
}

// Map<String, dynamic> _readItem(XmlElement xmlElement) {
//   Map<String, dynamic> json = {};

//   json = {
//     'properties': _readProperties(xmlElement.getElement("properties")),
//     'items': _readItems(xmlElement.getElement("items"))
//   };

//   return json;
// }
