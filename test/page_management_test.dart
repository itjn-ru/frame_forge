import 'package:flutter_test/flutter_test.dart';
import 'package:frame_forge/frame_forge.dart';

void main() {
  late LayoutModel layoutModel;
  late LayoutModelController controller;

  setUp(() {
    layoutModel = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    controller = LayoutModelController(
      layoutModel: layoutModel,
      projectSaver: (Map map) async => true,
      projectLoader: (bool isSaved) async => null,
    );
  });

  group('componentPages / nextPageName', () {
    test('layout starts with a single page named page', () {
      expect(layoutModel.componentPages.length, 1);
      expect(layoutModel.componentPages.first['name'], 'page');
    });

    test('nextPageName skips names already used', () {
      expect(layoutModel.nextPageName(), 'page 2');
      controller.addPage(name: 'page 2');
      expect(layoutModel.nextPageName(), 'page 3');
    });
  });

  group('switchPage', () {
    test('updates current page and selection', () {
      controller.addPage();
      final ComponentPage second = layoutModel.componentPages.last;
      final ComponentPage first = layoutModel.componentPages.first;

      controller.switchPage(second);
      expect(layoutModel.curPage, second);
      expect(controller.selectedId, second.id);
      expect(controller.currentComponentPage, second);

      controller.switchPage(first);
      expect(layoutModel.curPage, first);
      expect(controller.currentComponentPage, first);
    });
  });

  group('addPage', () {
    test('creates a page with unique auto name and switches to it', () {
      controller.addPage();
      expect(layoutModel.componentPages.length, 2);
      final ComponentPage added = layoutModel.componentPages.last;
      expect(added['name'], 'page 2');
      expect(controller.selectedId, added.id);
      expect(layoutModel.curPage, added);
    });

    test('is undoable', () {
      controller.addPage();
      controller.undo();
      expect(layoutModel.componentPages.length, 1);
      controller.redo();
      expect(layoutModel.componentPages.length, 2);
    });
  });

  group('duplicatePage', () {
    test('creates a deep copy with fresh ids and switches to it', () {
      final ComponentPage original = layoutModel.componentPages.first;
      original.items.add(Item('text', 'hello'));
      final String childId = original.items.first.id;

      controller.duplicatePage(original);

      expect(layoutModel.componentPages.length, 2);
      final ComponentPage copy = layoutModel.componentPages.last;
      expect(copy['name'], 'page copy');
      expect(copy.id, isNot(original.id));
      expect(copy.items.length, 1);
      expect(copy.items.first.id, isNot(childId));
      expect(controller.currentComponentPage, copy);
    });

    test('is undoable', () {
      final ComponentPage original = layoutModel.componentPages.first;
      controller.duplicatePage(original);
      controller.undo();
      expect(layoutModel.componentPages.length, 1);
    });
  });

  group('renamePage', () {
    test('changes the page name', () {
      final ComponentPage page = layoutModel.componentPages.first;
      controller.renamePage(page, 'главная');
      expect(page['name'], 'главная');
    });

    test('ignores blank names', () {
      final ComponentPage page = layoutModel.componentPages.first;
      controller.renamePage(page, '   ');
      expect(page['name'], 'page');
    });
  });

  group('deletePage', () {
    test('removes the page and selects its neighbour', () {
      controller.addPage();
      final ComponentPage first = layoutModel.componentPages.first;

      controller.deletePage(first);

      expect(layoutModel.componentPages.length, 1);
      expect(controller.selectedId, layoutModel.componentPages.first.id);
    });

    test('keeps at least one page', () {
      controller.deletePage(layoutModel.componentPages.first);
      expect(layoutModel.componentPages.length, 1);
    });

    test('is undoable', () {
      controller.addPage();
      controller.deletePage(layoutModel.componentPages.first);
      expect(layoutModel.componentPages.length, 1);
      controller.undo();
      expect(layoutModel.componentPages.length, 2);
    });
  });
}