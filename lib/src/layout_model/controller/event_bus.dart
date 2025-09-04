import 'dart:async';

import 'events.dart';

/// Класс, который действует как шина событий.
///
/// Этот класс отвечает за обработку и отправку событий, связанных
/// с [LayoutModelController]. Он позволяет различным частям приложения
/// взаимодействовать друг с другом путем отправки и получения событий.
///
/// Events can object instances should extend the [NodeEditorEvent] class.
class LayoutModelEventBus {
  final _streamController = StreamController<LayoutModelEvent>.broadcast();

  /// Emits an event to the event bus.
  void emit(LayoutModelEvent event) {
    _streamController.add(event);
  }

  /// Closes the underlying stream controller.
  void close() {
    _streamController.close();
  }

  Stream<LayoutModelEvent> get events => _streamController.stream;
}
