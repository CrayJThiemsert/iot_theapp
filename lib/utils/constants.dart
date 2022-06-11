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

  // Tank Types
  static const Map<String, Map<String, String>> gTankTypesMap = {
    "Horizontal Cylinder": {'Length (l)': 'l', 'Diameter (d)': 'd'},
    "Vertical Cylinder": {'Length (l)': 'l', 'Diameter (d)': 'd'},
    "Rectangle": {'Height (h)': 'h', 'Width (w)': 'w', 'Length (l)': 'l'},
    "Horizontal Oval": {'Height (h)': 'h', 'Width (w)': 'w', 'Length (l)': 'l'},
    "Vertical Oval": {'Height (h)': 'h', 'Width (w)': 'w', 'Length (l)': 'l'},
    "Horizontal Capsule": {'Side Length (a)': 'a', 'Diameter (d)': 'd'},
    "Vertical Capsule": {'Side Length (a)': 'a', 'Diameter (d)': 'd'},
    "Horizontal 2:1 Elliptical": {'Side Length (a)': 'a', 'Diameter (d)': 'd'},
    "Horizontal Dish Ends": {'Side Length (a)': 'a', 'Diameter (d)': 'd'},
    "Horizontal Ellipse": {'Height (h)': 'h', 'Width (w)': 'w', 'Length (l)': 'l'},
  };

  static const Map<String, String> gTankImagesMap = {
    "Horizontal Cylinder": 'images/tanks/base_horizontal_cylinder.jpg',
    "Vertical Cylinder": 'images/tanks/base_vertical_cylinder.jpg',
    "Rectangle": 'images/tanks/base_rectangle.jpg',
    "Horizontal Oval": 'images/tanks/base_horizontal_oval.jpg',
    "Vertical Oval": 'images/tanks/base_vertical_oval.jpg',
    "Horizontal Capsule": 'images/tanks/base_horizontal_capsule.jpg',
    "Vertical Capsule": 'images/tanks/base_vertical_capsule.jpg',
    "Horizontal 2:1 Elliptical": 'images/tanks/base_horizontal_2_1_elliptical.jpg',
    "Horizontal Dish Ends": 'images/tanks/base_horizontal_dish_ends.jpg',
    "Horizontal Ellipse": 'images/tanks/base_horizontal_ellipse.jpg',
  };

  // static const xx = TextStyle(
  //   color: Colors.white,
  //   fontFamily: 'Kanit',
  //   fontWeight: FontWeight.w300,
  //   fontSize: 12.0,
  // );
  @override
  bool updateShouldNotify(Constants oldWidget) => false;
}