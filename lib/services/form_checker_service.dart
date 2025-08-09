import 'dart:math';
import 'package:google_ml_kit/google_ml_kit.dart';

class FormCheckerService {
  static const double _angleThreshold = 15.0; // degrees

  static String? checkSquatForm(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

    if (leftKnee == null || rightKnee == null || leftHip == null || 
        rightHip == null || leftAnkle == null || rightAnkle == null) {
      return null;
    }

    // Check knee angle (should be around 90 degrees at bottom)
    final leftKneeAngle = _calculateAngle(leftHip, leftKnee, leftAnkle);
    final rightKneeAngle = _calculateAngle(rightHip, rightKnee, rightAnkle);

    if (leftKneeAngle < 70 || rightKneeAngle < 70) {
      return "Go deeper in your squat";
    }
    if (leftKneeAngle > 110 || rightKneeAngle > 110) {
      return "Good depth, now push through your heels";
    }

    // Check if knees are tracking over toes
    if ((leftKnee.x - leftAnkle.x).abs() > 50) {
      return "Keep your knees aligned over your toes";
    }

    return "Perfect form, keep it up!";
  }

  static String? checkPushUpForm(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null || rightShoulder == null || leftElbow == null || 
        rightElbow == null || leftWrist == null || rightWrist == null ||
        leftHip == null || rightHip == null) {
      return null;
    }

    // Check elbow angle
    final leftElbowAngle = _calculateAngle(leftShoulder, leftElbow, leftWrist);
    final rightElbowAngle = _calculateAngle(rightShoulder, rightElbow, rightWrist);

    if (leftElbowAngle < 70 || rightElbowAngle < 70) {
      return "Lower your chest more";
    }
    if (leftElbowAngle > 110 || rightElbowAngle > 110) {
      return "Good depth, now push up";
    }

    return "Excellent push-up form!";
  }

  static double _calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final ab = Point(a.x - b.x, a.y - b.y);
    final cb = Point(c.x - b.x, c.y - b.y);
    
    final dotProduct = ab.x * cb.x + ab.y * cb.y;
    final magnitudeAB = sqrt(ab.x * ab.x + ab.y * ab.y);
    final magnitudeCB = sqrt(cb.x * cb.x + cb.y * cb.y);
    
    final cosAngle = dotProduct / (magnitudeAB * magnitudeCB);
    final angleRad = acos(cosAngle.clamp(-1.0, 1.0));
    
    return angleRad * 180 / pi;
  }
}