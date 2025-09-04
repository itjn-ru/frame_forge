import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class GridBackgroundBuilder extends StatelessWidget {
  const GridBackgroundBuilder({
    super.key,
    required this.cellWidth,
    required this.cellHeight,
    required this.canvasWidth,
    required this.quad,
  });

  final double cellWidth;
  final double cellHeight;
  final Quad quad;
  final double canvasWidth;

  @override
  Widget build(BuildContext context) {
    final Rect rect = axisAlignedBoundingBox(quad);
    final int firstRow = (rect.top / cellHeight).floor();
    final int lastRow = (rect.bottom / cellHeight).ceil();
    return ListView(children: [
      for (int col = firstRow; col < lastRow; col++) dotsRow(rect),
    ]);
  }

  Widget dotsRow(Rect rect) {
    final int firstCol = (rect.left / cellWidth).floor();
    final int lastCol = (rect.right / cellWidth).floor();
    List<Widget> dotsRow = [];
    for (int row = firstCol; row < lastCol; row++) {
      dotsRow.add(dot());
    }
    return Row(children: dotsRow);
  }

  Widget dot() {
    return SizedBox(
      height: cellHeight,
      width: cellWidth,
      child: const Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 1,
          height: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
            ),
          ),
        ),
      ),
    );
  }
  Rect axisAlignedBoundingBox(Quad quad) {
    double xMin = quad.point0.x;
    double xMax = quad.point0.x;
    double yMin = quad.point0.y;
    double yMax = quad.point0.y;

    for (final point in <Vector3>[
      quad.point1,
      quad.point2,
      quad.point3,
    ]) {
      if (point.x < xMin) {
        xMin = point.x;
      } else if (point.x > xMax) {
        xMax = point.x;
      }

      if (point.y < yMin) {
        yMin = point.y;
      } else if (point.y > yMax) {
        yMax = point.y;
      }
    }

    return Rect.fromLTRB(0, 0, canvasWidth, yMax);
  }
}
