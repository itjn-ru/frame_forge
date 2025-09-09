import 'package:uuid/uuid.dart';
import '../events.dart';
import '../event_bus.dart';
import '../undo.dart';
import '../interfaces/undo_redo_service.dart';

/// Implementation of UndoRedoService
class UndoRedoServiceImpl implements UndoRedoService {
  final LayoutModelEventBus _eventBus;
  final List<UndoableAction> _undoStack = <UndoableAction>[];
  final List<UndoableAction> _redoStack = <UndoableAction>[];

  UndoRedoServiceImpl(this._eventBus);

  @override
  bool get canUndo => _undoStack.isNotEmpty;

  @override
  bool get canRedo => _redoStack.isNotEmpty;

  @override
  void undo() {
    // This method should not be called directly
    // Use executeUndo() instead to provide callback
    throw UnsupportedError('Use executeUndo() with callback instead');
  }

  @override
  void redo() {
    // This method should not be called directly
    // Use executeRedo() instead to provide callback
    throw UnsupportedError('Use executeRedo() with callback instead');
  }

  @override
  void pushAction(UndoableAction action) {
    _undoStack.add(action);
    _redoStack.clear();
  }

  @override
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  /// Internal access for controller to execute actions
  void executeUndo(void Function(UndoableAction) callback) {
    if (!canUndo) return;
    final UndoableAction action = _undoStack.removeLast();
    callback(action);
    _redoStack.add(action);
    _eventBus.emit(UndoPerformed(id: const Uuid().v4()));
  }

  void executeRedo(void Function(UndoableAction) callback) {
    if (!canRedo) return;
    final UndoableAction action = _redoStack.removeLast();
    callback(action);
    _undoStack.add(action);
    _eventBus.emit(RedoPerformed(id: const Uuid().v4()));
  }
}
