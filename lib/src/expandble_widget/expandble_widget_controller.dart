import 'dart:async';

abstract class ExpandableController {
  bool get isExpanded;
  double? get expandedHeight;
  void toggle();
  void expand();
  void collapse();
  Stream<bool> get stateChanges;
  Stream<double?> get heightChanges;
  void updateHeight(double height);
  void dispose();
}

class ExpandableControllerImpl implements ExpandableController {
  // current state values (seeded)
  bool _isExpanded = false;
  double? _expandedHeight;

  // controllers for broadcasting changes
  final StreamController<bool> _stateController = StreamController<bool>.broadcast();
  final StreamController<double?> _heightController = StreamController<double?>.broadcast();

  @override
  bool get isExpanded => _isExpanded;

  @override
  double? get expandedHeight => _expandedHeight;

  @override
  void toggle() {
    _isExpanded = !_isExpanded;
    _stateController.add(_isExpanded);
  }

  @override
  void expand() {
    _isExpanded = true;
    _stateController.add(_isExpanded);
  }

  @override
  void collapse() {
    _isExpanded = false;
    _stateController.add(_isExpanded);
  }

  // Provide a stream that immediately emits the current value for new listeners,
  // then forwards subsequent events from the broadcast controller.
  @override
  Stream<bool> get stateChanges async* {
    yield _isExpanded;
    yield* _stateController.stream;
  }

  @override
  Stream<double?> get heightChanges async* {
    yield _expandedHeight;
    yield* _heightController.stream;
  }

  @override
  void updateHeight(double height) {
    _expandedHeight = height;
    _heightController.add(height);
  }

  @override
  void dispose() {
    _stateController.close();
    _heightController.close();
  }
}
