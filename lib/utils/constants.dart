import 'package:flutter/material.dart';

class Constants extends InheritedWidget {
  static Constants? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Constants>();

  const Constants({required Widget child, Key? key}): super(key: key, child: child);

  final String successMessage = 'Some message';
  final String DEFAULT_THE_NODE_IP = "192.168.4.1"; // // "192.168.1.199";
  final String DEFAULT_THE_NODE_DNS = "thenode"; // thenode[macaddress] example is thenode84:CC:A8:88:6E:07

  static const MODE_BURST = "burst";
  static const MODE_POLLING = "polling";
  static const MODE_SETUP = "setup";
  static const MODE_REQUEST = "request";
  static const MODE_OFFLINE = "offline";

  static const INTERVAL_SECOND_10 = 10000;
  static const INTERVAL_SECOND_30 = 30000;
  static const INTERVAL_MINUTE_1 = 60000;
  static const INTERVAL_MINUTE_5 = 300000;
  static const INTERVAL_MINUTE_30 = 1800000;
  static const INTERVAL_HOUR_1 = 3600000;
  static const INTERVAL_HOUR_2 = 7200000;
  static const INTERVAL_HOUR_3 = 10800000;
  static const INTERVAL_HOUR_4 = 14400000;

  static const TEMP_LOWER = 1;
  static const TEMP_HIGHER = 2;
  static const HUMID_LOWER = 3;
  static const HUMID_HIGHER = 4;

  // TOF10120(Water Leveling Sensor) Constants
  /**
   * Tank Types
   */
  static const TANK_TYPE_SIMPLE = 'Simple';
  static const TANK_TYPE_HORIZONTAL_CYLINDER = 'Horizontal Cylinder';
  static const TANK_TYPE_VERTICAL_CYLINDER = 'Vertical Cylinder';
  static const TANK_TYPE_RECTANGLE = 'Rectangle';
  static const TANK_TYPE_HORIZONTAL_OVAL = 'Horizontal Oval';
  static const TANK_TYPE_VERTICAL_OVAL = 'Vertical Oval';
  static const TANK_TYPE_HORIZONTAL_CAPSULE = 'Horizontal Capsule';
  static const TANK_TYPE_VERTICAL_CAPSULE = 'Vertical Capsule';
  static const TANK_TYPE_HORIZONTAL_2_1_ELLIPTICAL = 'Horizontal 2:1 Elliptical';
  static const TANK_TYPE_HORIZONTAL_DISH_ENDS = 'Horizontal Dish Ends';
  static const TANK_TYPE_HORIZONTAL_ELLIPSE = 'Horizontal Ellipse';

  // Dimension Types
  static const DIMENSION_TYPE_CAPACITY = 'Capacity (c)';
  static const DIMENSION_TYPE_LENGTH = 'Length (l)';
  static const DIMENSION_TYPE_DIAMETER = 'Diameter (d)';
  static const DIMENSION_TYPE_HEIGHT = 'Height (h)';
  static const DIMENSION_TYPE_WIDTH = 'Width (w)';
  static const DIMENSION_TYPE_SIDE_LENGTH = 'Side Length (a)';

  // Tank Types
  static const Map<String, Map<String, String>> gTankTypesMap = {
    TANK_TYPE_SIMPLE: {DIMENSION_TYPE_HEIGHT: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_CAPACITY: VOLUME_TYPE_LITERS},
    TANK_TYPE_HORIZONTAL_CYLINDER: {DIMENSION_TYPE_LENGTH: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_DIAMETER: UNIT_TYPE_CENTIMETRE},
    TANK_TYPE_VERTICAL_CYLINDER: {DIMENSION_TYPE_HEIGHT: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_DIAMETER: UNIT_TYPE_CENTIMETRE},
    TANK_TYPE_RECTANGLE: {DIMENSION_TYPE_HEIGHT: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_WIDTH: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_LENGTH: UNIT_TYPE_CENTIMETRE},
    TANK_TYPE_HORIZONTAL_OVAL: {DIMENSION_TYPE_HEIGHT: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_WIDTH: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_LENGTH: UNIT_TYPE_CENTIMETRE},
    TANK_TYPE_VERTICAL_OVAL: {DIMENSION_TYPE_HEIGHT: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_WIDTH: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_LENGTH: UNIT_TYPE_CENTIMETRE},
    TANK_TYPE_HORIZONTAL_CAPSULE: {DIMENSION_TYPE_SIDE_LENGTH: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_DIAMETER: UNIT_TYPE_CENTIMETRE},
    TANK_TYPE_VERTICAL_CAPSULE: {DIMENSION_TYPE_SIDE_LENGTH: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_DIAMETER: UNIT_TYPE_CENTIMETRE},
    TANK_TYPE_HORIZONTAL_2_1_ELLIPTICAL: {DIMENSION_TYPE_SIDE_LENGTH: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_DIAMETER: UNIT_TYPE_CENTIMETRE},
    TANK_TYPE_HORIZONTAL_DISH_ENDS: {DIMENSION_TYPE_SIDE_LENGTH: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_DIAMETER: UNIT_TYPE_CENTIMETRE},
    TANK_TYPE_HORIZONTAL_ELLIPSE: {DIMENSION_TYPE_HEIGHT: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_WIDTH: UNIT_TYPE_CENTIMETRE, DIMENSION_TYPE_LENGTH: UNIT_TYPE_CENTIMETRE},
  };

  static const Map<String, String> gTankImagesMap = {
    TANK_TYPE_SIMPLE: 'images/tanks/base_simple.jpg',
    TANK_TYPE_HORIZONTAL_CYLINDER: 'images/tanks/base_horizontal_cylinder.jpg',
    TANK_TYPE_VERTICAL_CYLINDER: 'images/tanks/base_vertical_cylinder.jpg',
    TANK_TYPE_RECTANGLE: 'images/tanks/base_rectangle.jpg',
    TANK_TYPE_HORIZONTAL_OVAL: 'images/tanks/base_horizontal_oval.jpg',
    TANK_TYPE_VERTICAL_OVAL: 'images/tanks/base_vertical_oval.jpg',
    TANK_TYPE_HORIZONTAL_CAPSULE: 'images/tanks/base_horizontal_capsule.jpg',
    TANK_TYPE_VERTICAL_CAPSULE: 'images/tanks/base_vertical_capsule.jpg',
    TANK_TYPE_HORIZONTAL_2_1_ELLIPTICAL: 'images/tanks/base_horizontal_2_1_elliptical.jpg',
    TANK_TYPE_HORIZONTAL_DISH_ENDS: 'images/tanks/base_horizontal_dish_ends.jpg',
    TANK_TYPE_HORIZONTAL_ELLIPSE: 'images/tanks/base_horizontal_ellipse.jpg',
  };

  /**
   * Length unit types
   */
  static const UNIT_TYPE_INCH = 'in';
  static const UNIT_TYPE_FOOT = 'ft';
  static const UNIT_TYPE_MILLIMETRE = 'mm';
  static const UNIT_TYPE_CENTIMETRE = 'cm';
  static const UNIT_TYPE_METRE = 'm';

  static const VOLUME_TYPE_US_GALLONS = 'U.S. Gallons';
  static const VOLUME_TYPE_IMP_GALLONS = 'Imp. Gallons';
  static const VOLUME_TYPE_LITERS = 'Liters';
  static const VOLUME_TYPE_CUBIC_METERS = 'Cubic Meters';
  static const VOLUME_TYPE_CUBIC_FEET = 'Cubic Feet';

  static double pie=3.14285714286;

  // static const xx = TextStyle(
  //   color: Colors.white,
  //   fontFamily: 'Kanit',
  //   fontWeight: FontWeight.w300,
  //   fontSize: 12.0,
  // );
  @override
  bool updateShouldNotify(Constants oldWidget) => false;
}