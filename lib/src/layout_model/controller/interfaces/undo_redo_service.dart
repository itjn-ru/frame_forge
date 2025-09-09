import '../undo.dart';

/// Interface for undo/redo operations
abstract class UndoRedoService {
  /// Check if undo is available
  bool get canUndo;
  
  /// Check if redo is available
  bool get canRedo;
  
  /// Perform undo operation
  void undo();
  
  /// Perform redo operation
  void redo();
  
  /// Push new action to undo stack
  void pushAction(UndoableAction action);
  
  /// Clear all undo/redo history
  void clear();
}
