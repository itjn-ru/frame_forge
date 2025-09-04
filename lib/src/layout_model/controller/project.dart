import 'package:uuid/uuid.dart';

import '../file.dart';
import 'events.dart';
import 'helpers/snackbar.dart';
import 'layout_model_controller.dart';

class LayoutModelEditorProject {
  final LayoutModelController controller;

  bool _isSaved = true;

  bool get isSaved => _isSaved;

  final Future<bool> Function(Map map)? projectSaver;
  final Future<String?> Function(bool isSaved)? projectLoader;
  final Future<bool> Function(bool isSaved)? projectCreator;

  LayoutModelEditorProject(
    this.controller, {
    required this.projectSaver,
    required this.projectLoader,
    required this.projectCreator,
  }) {
    controller.eventBus.events.listen(_handleProjectEvents);
  }

  /// Обработчик событий.
  ///
  /// - [SaveProjectEvent]: Устанавливает проект как сохраненный.
  /// - [LoadProjectEvent]: Устанавливает проект как сохраненный и чистит историю.
  /// - [NewProjectEvent]: Очищает проект и генерирует новый.
  ///
  /// Если событие невозможно выполнить, проект устанавливается как несохраненный.
  void _handleProjectEvents(LayoutModelEvent event) {
    if (event.isUndoable) _isSaved = false;

    if (event is SaveProjectEvent) {
      _isSaved = true;
    } else if (event is LoadProjectEvent) {
      _isSaved = true;

      ///TODO сделать историю изменений
      /// controller.history.clear();
    } else if (event is NewProjectEvent) {
      _isSaved = true;
      controller.clear();
    }
  }

  void save() async {
    late final Map map;
    try {
      map = controller.layoutModel.toMap();
    } catch (e) {
      showNodeEditorSnackbar(
        'Ошибка сохранения, Неверные данные.',
        SnackbarType.error,
      );
      return;
    }

    if (map.isEmpty) return;

    final hasSaved = await projectSaver?.call(map);
    if (hasSaved == false) return;

    _isSaved = true;

    controller.eventBus.emit(SaveProjectEvent(id: const Uuid().v4()));

    showNodeEditorSnackbar('Макет успешно сохранен', SnackbarType.success);
  }

  void load({String? data}) async {
    late final Map<String, dynamic>? map;
    data ??= await projectLoader?.call(isSaved);

    if (data == null) {
      showNodeEditorSnackbar(
        'Не удалось загрузить макет. Неверные данные.',
        SnackbarType.error,
      );
      return;
    }

    controller.clear();

    try {
      map = readMap(data);
    } catch (e) {
      showNodeEditorSnackbar(
        'Не удалось загрузить макет. Не удается обработать данные.',
        SnackbarType.error,
      );
      return;
    }
    controller.layoutModel.fromMap(map);
    controller.eventBus.emit(LoadProjectEvent(id: const Uuid().v4()));

    showNodeEditorSnackbar(
      'Макет загружен успешно.',
      SnackbarType.success,
    );
  }

  void create(){
    try {
    controller.layoutModel.init();
    } catch (e) {
      showNodeEditorSnackbar(
        'Не удалось создать новый проект',
        SnackbarType.error,
      );
      return;
    }
    controller.eventBus.emit(NewProjectEvent(id: const Uuid().v4()));
    showNodeEditorSnackbar(
      'Создан новый проект',
      SnackbarType.success,
    );
  }
}
