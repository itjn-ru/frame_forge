import 'package:flutter/material.dart';
import '../item.dart';
import 'layout_model_controller.dart';

/// Base contract for undoable actions that can apply and revert changes
abstract class UndoableAction {
  void apply(LayoutModelController controller);
  void revert(LayoutModelController controller);
}

class MoveAction implements UndoableAction {
  final String itemId;
  final Offset from;
  final Offset to;

  MoveAction({required this.itemId, required this.from, required this.to});

  @override
  void apply(LayoutModelController controller) {
    controller.applyPosition(itemId, to);
  }

  @override
  void revert(LayoutModelController controller) {
    controller.applyPosition(itemId, from);
  }
}

class ResizeAction implements UndoableAction {
  final String itemId;
  final Size from;
  final Size to;

  ResizeAction({required this.itemId, required this.from, required this.to});

  @override
  void apply(LayoutModelController controller) {
    controller.applySize(itemId, to);
  }

  @override
  void revert(LayoutModelController controller) {
    controller.applySize(itemId, from);
  }
}

class ResizeMoveAction implements UndoableAction {
  final String itemId;
  final Size fromSize;
  final Size toSize;
  final Offset fromPos;
  final Offset toPos;

  ResizeMoveAction({
    required this.itemId,
    required this.fromSize,
    required this.toSize,
    required this.fromPos,
    required this.toPos,
  });

  @override
  void apply(LayoutModelController controller) {
    controller.applySize(itemId, toSize);
    if (toPos != fromPos) {
      controller.applyPosition(itemId, toPos, emitDelta: toPos - fromPos);
    }
  }

  @override
  void revert(LayoutModelController controller) {
    controller.applySize(itemId, fromSize);
    if (toPos != fromPos) {
      controller.applyPosition(itemId, fromPos, emitDelta: fromPos - toPos);
    }
  }
}

class DeleteAction implements UndoableAction {
  final String itemId;
  final Item parent;
  final int index;
  final Item snapshot;

  DeleteAction({
    required this.itemId,
    required this.parent,
    required this.index,
    required this.snapshot,
  });

  @override
  void apply(LayoutModelController controller) {
    controller.applyDelete(itemId);
  }

  @override
  void revert(LayoutModelController controller) {
    controller.applyInsertDirect(parent, snapshot, index: index);
    // Select the restored item
    controller.select(itemId);
  }
}

class InsertAction implements UndoableAction {
  final Item parent;
  final int? index;
  final Item snapshot;

  InsertAction({
    required this.parent,
    required this.snapshot,
    this.index,
  });

  @override
  void apply(LayoutModelController controller) {
    controller.applyInsertDirect(parent, snapshot, index: index);
  }

  @override
  void revert(LayoutModelController controller) {
    controller.applyDelete(snapshot.id);
  }
}
