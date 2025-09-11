import 'grid_snap.dart';
abstract class SnapPolicy {
  double snapX(double x);
  double snapY(double y);
}

class NoSnapPolicy implements SnapPolicy {
  const NoSnapPolicy();
  @override
  double snapX(double x) => x;
  @override
  double snapY(double y) => y;
}

class GridSnapPolicy implements SnapPolicy {
  final double stepX;
  final double stepY;
  final bool enabled;
  final GridSnapper _snapper;

  GridSnapPolicy({required this.stepX, required this.stepY, this.enabled = true})
      : _snapper = GridSnapper(stepX: stepX, stepY: stepY);

  GridSnapPolicy copyWith({double? stepX, double? stepY, bool? enabled}) =>
      GridSnapPolicy(
        stepX: stepX ?? this.stepX,
        stepY: stepY ?? this.stepY,
        enabled: enabled ?? this.enabled,
      );

  @override
  double snapX(double x) => enabled ? _snapper.snapX(x) : x;
  @override
  double snapY(double y) => enabled ? _snapper.snapY(y) : y;
}
