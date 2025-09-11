import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../item.dart';
import 'layout_model_controller.dart';

/// Global keyboard handler that processes shortcuts at the application level.
/// 
/// This ensures keyboard shortcuts work regardless of focus state or widget hierarchy.
class GlobalKeyboardHandler {
  final LayoutModelController controller;

  GlobalKeyboardHandler(this.controller);

  /// Handles keyboard events globally
  bool handleKeyEvent(KeyEvent event) {
    // Only process key down events
    if (event is! KeyDownEvent) return false;

    final bool isCtrl = HardwareKeyboard.instance.isControlPressed;
    final bool isShift = HardwareKeyboard.instance.isShiftPressed;
    final bool isAlt = HardwareKeyboard.instance.isAltPressed;

    // Undo / Redo
    if (isCtrl && event.physicalKey == PhysicalKeyboardKey.keyZ) {
      if (isShift) {
        controller.redo();
      } else {
        controller.undo();
      }
      return true;
    }
    
    if (isCtrl && event.physicalKey == PhysicalKeyboardKey.keyY) {
      controller.redo();
      return true;
    }

    // Copy / Paste / Cut (only if not editing a text field)
    if (isCtrl && event.physicalKey == PhysicalKeyboardKey.keyC && !_isTextFieldFocused()) {
      controller.clipboard.copySelection();
      return true;
    }
    
    if (isCtrl && event.physicalKey == PhysicalKeyboardKey.keyV && !_isTextFieldFocused()) {
      final String? selId = controller.selectedId;
      final Item? parent = selId != null
          ? controller.getItemById(selId)
          : controller.getCurrentPage();
      if (parent != null) {
        controller.clipboard.pasteSelection(parent: parent);
      }
      return true;
    }
    
    if (isCtrl && event.physicalKey == PhysicalKeyboardKey.keyX && !_isTextFieldFocused()) {
      controller.clipboard.cutSelection();
      return true;
    }

    if (event.physicalKey == PhysicalKeyboardKey.delete ||
        event.physicalKey == PhysicalKeyboardKey.backspace) {
      if (controller.selectedId != null && !_isTextFieldFocused()) {
        controller.deleteSelected();
        return true;
      }
    }

    // Arrow keys for movement
    final String? selectedId = controller.selectedId;
    if (selectedId != null) {
      final double baseStepX = isAlt ? 1.0 : controller.gridStepX;
      final double baseStepY = isAlt ? 1.0 : controller.gridStepY;
      final double multiplier = isShift ? 5.0 : 1.0;
      final double stepX = baseStepX * multiplier;
      final double stepY = baseStepY * multiplier;

      Offset? delta;
      if (event.physicalKey == PhysicalKeyboardKey.arrowLeft) {
        delta = Offset(-stepX, 0);
      } else if (event.physicalKey == PhysicalKeyboardKey.arrowRight) {
        delta = Offset(stepX, 0);
      } else if (event.physicalKey == PhysicalKeyboardKey.arrowUp) {
        delta = Offset(0, -stepY);
      } else if (event.physicalKey == PhysicalKeyboardKey.arrowDown) {
        delta = Offset(0, stepY);
      }

      if (delta != null) {
        controller.moveItemById(selectedId, delta, snap: false);
        return true;
      }
    }

    return false;
  }

  bool _isTextFieldFocused() {
    final FocusNode? focusedNode = FocusManager.instance.primaryFocus;
    if (focusedNode == null) return false;
    
    final BuildContext? context = focusedNode.context;
    if (context == null) return false;
    
    bool isTextField = false;
    context.visitAncestorElements((Element element) {
      final Widget widget = element.widget;
      if (widget is TextField || 
          widget is TextFormField || 
          widget is EditableText) {
        isTextField = true;
        return false;
      }
      return true;
    });
    
    return isTextField;
  }
}
