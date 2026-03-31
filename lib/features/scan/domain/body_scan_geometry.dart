import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Calculates Euclidean distance between two landmarks.
double distanceBetweenLandmarks(PoseLandmark first, PoseLandmark second) {
  return sqrt(pow(second.x - first.x, 2) + pow(second.y - first.y, 2));
}

/// Calculates Euclidean distance between two 2D points.
double distanceBetweenPoints(Point<double> first, Point<double> second) {
  return sqrt(pow(second.x - first.x, 2) + pow(second.y - first.y, 2));
}

/// Finds the midpoint between two landmarks.
Point<double> midpointBetweenLandmarks(
  PoseLandmark first,
  PoseLandmark second,
) {
  return Point((first.x + second.x) / 2, (first.y + second.y) / 2);
}
