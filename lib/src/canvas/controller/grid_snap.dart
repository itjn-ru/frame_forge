
/// Utility to snap values to a grid in model space with precision cleanup.
class GridSnapper {
  final double stepX;
  final double stepY;

  GridSnapper({required this.stepX, required this.stepY});

  int _precisionFromStep(double step) {
    const maxP = 6;
    int p = 0;
    double s = step.abs();
    while (p < maxP && (s - s.truncateToDouble()).abs() > 1e-9) {
      s *= 10;
      p++;
    }
    return p;
  }

  double snapToStep(double value, double step) {
    if (step == 0) return value;
    final n = (value / step).round();
    final snapped = n * step;
    final prec = _precisionFromStep(step);
    return double.parse(snapped.toStringAsFixed(prec));
  }

  double snapX(double x) => snapToStep(x, stepX);
  double snapY(double y) => snapToStep(y, stepY);
}
