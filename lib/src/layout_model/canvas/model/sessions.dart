import 'resize_types.dart';

class ResizeSession {
  double leftM;
  double topM;
  double rightM;
  double bottomM;
  ResizeDirection direction;
  ResizeSession({
    required this.leftM,
    required this.topM,
    required this.rightM,
    required this.bottomM,
    required this.direction,
  });
}

class MoveSession {
  double leftM;
  double topM;
  MoveSession({required this.leftM, required this.topM});
}
