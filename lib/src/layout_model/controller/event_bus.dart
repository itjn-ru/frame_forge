import 'dart:async';

import 'events.dart';

/// Events can object instances should extend the [NodeEditorEvent] class.
/// A class that acts as an event bus.
/// This class is responsible for handling and dispatching events related
/// to the [LayoutModelController]. It allows different parts of the application
/// to communicate with each other by sending and receiving events.
/// Events should be instances of classes that extend the [LayoutModelEvent] class.
class LayoutModelEventBus {
  /// Underlying stream controller for broadcasting events.
  final StreamController<LayoutModelEvent> _streamController = StreamController<LayoutModelEvent>.broadcast();

  /// Emits an event to the event bus.
  void emit(LayoutModelEvent event) {
    _streamController.add(event);
  }

  /// Closes the underlying stream controller.
  void close() {
    _streamController.close();
  }

  /// Provides a stream of events for listeners to subscribe to.
  Stream<LayoutModelEvent> get events => _streamController.stream;
}
