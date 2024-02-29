import 'dart:math' as math;

// Helper functions
class HelperFun {
  static double getWindIconAngle(String windDirection) {
    var windIconAngle = 0.0;

    switch (windDirection) {
      case 'E':
        windIconAngle = (-math.pi / 4);
        break;
      case 'S':
        windIconAngle = math.pi / 4;
        break;
      case 'W':
        windIconAngle = (math.pi / 4) + (math.pi / 2);
        break;
      case 'N':
        windIconAngle = (math.pi / 4) + (math.pi);
        break;

      ///------------------------------
      case 'NW':
        windIconAngle = math.pi;
        break;
      case 'NE':
        windIconAngle = -math.pi / 2;
        break;
      case 'SE':
        windIconAngle = 0.0;
        break;
      case 'SW':
        windIconAngle = math.pi / 2;
        break;

      ///------------------------------
      case 'SSE':
        windIconAngle = math.pi / 8;
        break;
      case 'SSW':
        windIconAngle = 3 * math.pi / 8;
        break;
      case 'WSW':
        windIconAngle = 5 * math.pi / 8;
        break;
      case 'WNW':
        windIconAngle = 7 * math.pi / 8;
        break;
      case 'NNW':
        windIconAngle = 9 * math.pi / 8;
        break;
      case 'NNE':
        windIconAngle = 11 * math.pi / 8;
        break;
      case 'ENE':
        windIconAngle = 13 * math.pi / 8;
        break;
      case 'ESE':
        windIconAngle = 15 * math.pi / 8;
        break;
    }
    windIconAngle = windIconAngle - (math.pi / 20); // -(math.pi / 20) => correction of original icon
    // flip by 180 degrees
    windIconAngle = windIconAngle + math.pi;
    return windIconAngle;
  }
}
