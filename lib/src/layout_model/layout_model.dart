import 'package:uuid/uuid.dart';

import 'component_group.dart';
import 'component_table.dart';
import 'constants.dart';
import 'from_map_to_map_mixin.dart';
import 'item.dart';
import 'page.dart';
import 'property.dart';
import 'root.dart';
import 'screen_size_enum.dart';
import 'style.dart';
import 'style_element.dart';
import 'component_and_source.dart';

/// Core model for managing dynamic UI layouts.
///
/// [LayoutModel] represents the entire layout structure including components,
/// styles, data sources, and processes. It supports multiple screen sizes
/// and provides methods for managing the layout hierarchy.
///
/// Example:
/// ```dart
/// final model = LayoutModel(
///   screenSizes: [ScreenSizeEnum.mobile, ScreenSizeEnum.desktop],
/// );
/// ```
class LayoutModel with FromMapToMap {
  late Root root;
  late ComponentAndSourcePage curPage;

  Item? _curComponentItem;
  Item? _curSourceItem;
  // _curStyleItem removed as it was unused
  /// Supported screen sizes for responsive design
  ///
  /// Defines which screen size configurations are supported by this model.
  final List<ScreenSizeEnum> screenSizes;

  /// Gets the current page based on the current item
  ///
  /// Returns a [ComponentAndSourcePage] that contains the current item.
  ComponentAndSourcePage get getCurPage => getPageByItem(curItem);

  /// The type of the currently active page
  ///
  /// Used to track which type of page is currently being viewed/edited.
  late Type curPageType;

  /// Gets the current active item
  ///
  /// Returns the item that is currently selected or being edited
  /// for the current page type.
  Item get curItem {
    return curItemOnPage[curPageType]!;
  }

  /// Gets the current component item
  ///
  /// Returns the currently selected component item or a default
  /// ComponentPage if none is set.
  Item get curComponentItem {
    return _curComponentItem ?? ComponentPage('страница');
  }

  /// Sets the current component item
  ///
  /// [value] The component item to set as current
  set curComponentItem(Item value) {
    _curComponentItem = value;
  }

  /// Gets the current source item
  ///
  /// Returns the currently selected source item or a default
  /// SourcePage if none is set.
  Item get curSourceItem {
    return _curSourceItem ?? SourcePage('страница данных');
  }

  /// Sets the current source item
  ///
  /// [value] The source item to set as current
  set curSourceItem(Item value) {
    _curSourceItem = value;
  }

  /// Gets the processes page
  ///
  /// Returns the first [ProcessPage] found in the root items.
  ProcessPage get processes {
    return root.items.whereType<ProcessPage>().first;
  }

  /// Gets all available styles
  ///
  /// Returns a list of [Style] objects extracted from the style page.
  /// Each style contains an ID and display name.
  List<Style> get styles {
    final styleList = <Style>[];

    final stylePage = root.items.whereType<StylePage>().first;

    final list = stylePage.items.whereType<StyleElement>();

    for (final style in list) {
      styleList.add(Style(style['id'], style['name']));
    }
    return styleList;
  }

  /// Gets a style element by its ID
  ///
  /// [id] The unique identifier of the style element
  ///
  /// Returns the [StyleElement] with the specified ID, or null if not found.
  StyleElement? getStyleElementById(String id) {
    final stylePage = root.items.whereType<StylePage>().first;

    final list = stylePage.items.whereType<StyleElement>();

    return list.where((element) => element['id'] == id).firstOrNull;
  }

  /// Maps items to their containing pages
  final Map<Item, ComponentAndSourcePage> _itemsOnPage = {};

  /// Maps items to their layout components
  final Map<Item, LayoutComponentAndSource> _itemsOnComponent = {};

  /// Maps page types to their current items
  final Map<Type, Item> curItemOnPage = {};

  /// Gets the layout component containing the specified item
  ///
  /// [item] The item to find the component for
  ///
  /// Returns the [LayoutComponentAndSource] containing the item,
  /// or null if the item is not in a component.
  LayoutComponentAndSource? getComponentByItem(Item item) {
    if (item is LayoutComponentAndSource) {
      return item;
    }

    return _itemsOnComponent[item];
  }

  /// Gets the page containing the specified item
  ///
  /// [item] The item to find the page for
  ///
  /// Returns the [ComponentAndSourcePage] containing the item.
  /// For root items, returns the first component page.
  ComponentAndSourcePage getPageByItem(Item item) {
    if (item is Root) {
      return item.items.whereType<ComponentPage>().first;
    }

    if (item is ComponentAndSourcePage) {
      return item;
    }

    return _itemsOnPage[item]!;
  }

  LayoutModel({required this.screenSizes}) {
    init();
  }

  /// Initializes the layout model with default structure
  ///
  /// Creates the root item and default pages (component, source, style, process).
  /// Sets up basic style elements and establishes page relationships.
  void init() {
    root = Root('макет');

    var curPage = ComponentPage('страница');
    curPageType = ComponentPage;
    curItemOnPage[ComponentPage] = root;
    root.items.add(curPage);

    final sourcePage = SourcePage('страница данных');

    root.items.add(sourcePage);
    curItemOnPage[SourcePage] = sourcePage;

    final stylePage = StylePage('страница стилей');
    root.items.add(stylePage);
    curItemOnPage[StylePage] = stylePage;

    final processPage = ProcessPage('процессы');
    root.items.add(processPage);
    curItemOnPage[ProcessPage] = processPage;

    final StyleElement basicElement = StyleElement('базовый стиль');
    basicElement.properties['id'] = Property(
      'идентификатор',
      UuidNil,
      type: String,
    );
    stylePage.items.add(basicElement);
    //curItemOnPage[StylePage] = basicElement;
    _setPageForItem(stylePage, basicElement);
  }

  /// Loads model data from a map structure
  ///
  /// [map] The map containing the layout model data to load
  ///
  /// Deserializes a layout model from a map structure, typically loaded
  /// from JSON or other serialized format. Ensures all required pages
  /// exist and sets up proper page relationships.
  void fromMap(Map map) {
    root = Root(map['properties']['name']);

    usedIds.clear();

    root
      ..properties = propertiesFromMap(map['properties'])
      ..items = _itemsFromMap(root, map['items']);
    curItemOnPage[ComponentPage] = root;

    if (root.items.whereType<ComponentPage>().isEmpty) {
      root.items.add(ComponentPage('страница'));
    }
    curPage = root.items.whereType<ComponentPage>().first;

    if (root.items.whereType<SourcePage>().isEmpty) {
      final sourcePage = SourcePage('страница данных');
      root.items.add(sourcePage);
      curItemOnPage[SourcePage] = sourcePage;
    } else {
      final sourcePage = root.items.whereType<SourcePage>().first;
      curItemOnPage[SourcePage] = sourcePage;
    }

    if (root.items.whereType<StylePage>().isEmpty) {
      final stylePage = StylePage('страница стилей');
      root.items.add(stylePage);
      curItemOnPage[StylePage] = stylePage;
    } else {
      final stylePage = root.items.whereType<StylePage>().first;
      curItemOnPage[StylePage] = stylePage;
    }

    if (root.items.whereType<ProcessPage>().isEmpty) {
      final processPage = ProcessPage('процессы');
      root.items.add(processPage);
      curItemOnPage[ProcessPage] = processPage;
    } else {
      final processPage = root.items.whereType<ProcessPage>().first;
      curItemOnPage[ProcessPage] = processPage;
    }

    //добавляем базовый стиль, если отсутствует в файле
    final stylePage = root.items.whereType<StylePage>().first;

    if (stylePage.items
        .whereType<StyleElement>()
        .where((element) => element['id'] == UuidNil)
        .isEmpty) {
      final StyleElement basicElement = StyleElement('базовый стиль');
      basicElement.properties['id'] = Property(
        'идентификатор',
        UuidNil,
        type: String,
      );
      stylePage.items.insert(0, basicElement);
      //curItemOnPage[StylePage] = basicElement;
      _setPageForItem(stylePage, basicElement);
    }
    //добавляем базовый стиль
  }

  /// Мапа для складирования properties для проверки на уникальность
  final Set<String> usedIds = {};

  // Функция для проверки и замены id
  void ensureUniqueIds(Map<String, dynamic> properties) {
    properties.forEach((key, value) {
      if (key == 'id' && value is Property && value.value is String) {
        String id = value.value;
        if (usedIds.contains(id)) {
          // Генерируем новый уникальный id
          final newId = const Uuid().v4();
          value.value = newId;
          usedIds.add(newId);
        } else {
          usedIds.add(id);
        }
      }
    });
  }

  List<Item> _itemsFromMap(Item parent, List list) {
    final List<Item> items = [];

    for (final element in list) {
      Item item = switchItem(element, parent);

      final itemProperties = propertiesFromMap(element['properties']);

      /// Проверка на уникальность id
      ensureUniqueIds(itemProperties);

      item.properties.forEach((key, value) {
        if (itemProperties.containsKey(key)) {
          if (key == 'fontSize') {
            item.properties[key]!.value =
                double.tryParse(itemProperties[key]?.value) ?? '11';
          }
          if (item.properties[key]?.type == itemProperties[key]?.type) {
            itemProperties[key]!.title = item.properties[key]!.title;
            item.properties[key] = itemProperties[key]!;
          }
        }
      });

      item.items = _itemsFromMap(item, element['items']);

      if (item is LayoutComponentAndSource) {
        //curComponent = item;
        if (item is! ComponentGroup) {
          for (final curItem in item.items) {
            _setComponentForItem(item, curItem);
          }
        }
      }

      if (item is ComponentAndSourcePage) {
        for (final curItem in item.items) {
          _setPageForItem(item, curItem);
        }
      }

      items.add(item);
    }

    return items;
  }

  Map toMap() {
    final Map map = {};

    map['layout'] = {
      'properties': propertiesToMap(root),
      'items': itemsToMap(root),
    };
    return map['layout'];
  }

  void addItem(Item parent, Item item, {int? index}) {
    if (item is ComponentPage) {
      var indexLastPage = root.items.lastIndexWhere(
        (element) => element.runtimeType == ComponentPage,
      );
      root.items.insert(index ?? ++indexLastPage, item);
    } else if (item is LayoutComponentAndSource) {
      //_curItem.items.add(item);

      parent.items.insert(index ?? parent.items.length, item);

      //curComponent = item is ComponentGroup ? null : item;

      final page = getPageByItem(parent);

      _setPageForItem(page, item);

      if (item is! ComponentGroup) {
        for (final subItem in item.items) {
          _setComponentForItem(item, subItem);
        }
      }
      //_setComponentForItem(item);
    } else {
      /*if (curComponent == null) {
        return;
      }

      var indexLastItem = _curItem.items
          .lastIndexWhere((element) => element.runtimeType == item.runtimeType);
      _curItem.items.insert(++indexLastItem, item);*/

      final component = getComponentByItem(parent);

      if (component == null) {
        return;
      }

      var indexLastItem = parent.items.lastIndexWhere(
        (element) => element.runtimeType == item.runtimeType,
      );
      parent.items.insert(index ?? ++indexLastItem, item);

      switch (item.runtimeType) {
        case const (ComponentTableColumn):
          component.items
              .where((element) => element.runtimeType == ComponentTableRowGroup)
              .forEach((rowGroup) {
                for (final row in rowGroup.items) {
                  final cell = ComponentTableCell('ячейка');
                  row.items.add(cell);

                  //_setComponentForItem(component, cell);
                }
              });

        case const (ComponentTableRowGroup):
          final row = ComponentTableRow('строка');
          item.items.add(row);
          //_setComponentForItem(component, row);

          component.items
              .where((element) => element.runtimeType == ComponentTableColumn)
              .forEach((rowGroup) {
                final cell = ComponentTableCell('ячейка');

                row.items.add(cell);
              });
        case const (ComponentTableRow):
          component.items
              .where((element) => element.runtimeType == ComponentTableColumn)
              .forEach((rowGroup) {
                final cell = ComponentTableCell('ячейка');

                item.items.add(cell);
              });

        default:
      }

      _setComponentForItem(component, item);
      final page = getPageByItem(parent);
      _setPageForItem(page, item);
    }
  }

  void deleteCurrentItem() {
    deleteItem(curItem);
  }

  Item? findParentById(Item _root, String targetId) {
    for (final child in _root.items) {
      // Проверяем, есть ли у текущего элемента properties с нужным id
      final hasTargetId = child.properties['id']?.value == targetId;

      if (hasTargetId) {
        return _root; // Возвращаем текущий элемент как родителя
      }

      // Рекурсивный поиск вглубь
      final found = findParentById(child, targetId);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  void deleteItem(Item item) {
    final parent = findParentById(root, item.id);
    if (parent != null) {
      parent.items.remove(item);
      return;
    }
  }

  _setPageForItem(ComponentAndSourcePage page, Item item) {
    _itemsOnPage[item] = page;

    for (final subItem in item.items) {
      _setPageForItem(page, subItem);
    }
  }

  void _setComponentForItem(LayoutComponentAndSource? component, Item item) {
    if (component == null) {
      return;
    }
    //_itemsOnComponent[_curComponent!] = _curComponent!;
    _itemsOnComponent[item] = component;

    for (final curItem in item.items) {
      _setComponentForItem(component, curItem);
    }
  }

  Item? addItemToParent(Item parent, Item item, Item pasteItem) {
    if (parent.items.isEmpty) return null;
    if (parent.items.contains(item)) {
      final index = parent.items.indexOf(item);
      addItem(parent, pasteItem, index: index);
      return parent;
    }
    for (var element in parent.items) {
      if (element.items.contains(item)) {
        final index = element.items.indexOf(item);
        addItem(element, pasteItem, index: index);
        return element;
      } else {
        var newParent = addItemToParent(element, item, pasteItem);
        if (newParent != null) return newParent;
      }
    }
    return null;
  }
}
