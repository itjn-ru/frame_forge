import 'resize_types.dart';

class ResizeSession {
  double leftM;
  double topM;
  double rightM;
  double bottomM;
  ResizeDirection direction;
  // Capture original size at the start of the resize (in model units)
  double startWidthM;
  double startHeightM;
  ResizeSession({
    required this.leftM,
    required this.topM,
    required this.rightM,
    required this.bottomM,
    required this.direction,
    required this.startWidthM,
    required this.startHeightM,
  });
}

class MoveSession {
  double leftM;
  double topM;
  MoveSession({required this.leftM, required this.topM});
}
