import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot_theapp/pages/device/database/device_database.dart';
import 'package:iot_theapp/pages/device/model/device.dart';
import 'package:iot_theapp/pages/device/model/notification.dart' as Notify;
import 'package:iot_theapp/pages/device/model/tank.dart';
import 'package:iot_theapp/pages/device/model/weather_history.dart';
import 'package:iot_theapp/pages/device/view/line_chart_live.dart';
import 'package:iot_theapp/pages/device/view/utils.dart';
import 'package:iot_theapp/pages/user/model/user.dart';
import 'package:iot_theapp/utils/constants.dart';

import 'package:http/http.dart' as http;
import 'package:iot_theapp/globals.dart' as globals;
import 'package:iot_theapp/utils/sizes_helpers.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:validators/validators.dart';

import '../../../line_chart_sample10.dart';
import 'indicator.dart';

class ShowDevicePage extends StatefulWidget {
  final String deviceUid;
  final Device device;

  final weekDays = const ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  final List<double> yValues = const [1.3, 1, 1.8, 1.5, 2.2, 1.8, 3];

  const ShowDevicePage(
      {Key? key, required this.deviceUid, required this.device})
      : super(key: key);

  @override
  _ShowDevicePageState createState() => _ShowDevicePageState(deviceUid, device);
}

class _ShowDevicePageState extends State<ShowDevicePage>
    with AfterLayoutMixin<ShowDevicePage> {
  String deviceUid = '';
  Device device = Device();
  Notify.Notification notification = Notify.Notification();
  Notify.Notification notificationDialog = Notify.Notification();
  static Tank tank = Tank();
  Tank tankDialog = Tank();
  var f = NumberFormat("###.##", "en_US");

  static final _capacityFormKey = GlobalKey<FormState>();
  static final _heightFormKey = GlobalKey<FormState>();
  static final _widthFormKey = GlobalKey<FormState>();
  static final _lengthFormKey = GlobalKey<FormState>();
  static final _diameterFormKey = GlobalKey<FormState>();
  static final _sideLengthFormKey = GlobalKey<FormState>();

  User user = const User(uid: 'cray');
  // late DeviceDatabase deviceDatabase;

  bool sec10Pressed = false;
  bool sec30Pressed = false;
  bool min1Pressed = false;
  bool min5Pressed = false;
  bool min30Pressed = false;
  bool hour1Pressed = false;
  bool hour2Pressed = false;
  bool hour3Pressed = false;
  bool hour4Pressed = false;

  bool burstePressed = false;
  bool requestPressed = false;
  bool pollingPressed = false;
  bool offlinePressed = false;

  int selectedInterval = 5000; // milliseconds

  // Draw Live Line Chart
  final Color tempColor = Colors.orangeAccent;
  final Color humidColor = Colors.blueAccent;

  final limitCount = 100;
  final tempPoints = <FlSpot>[];
  final humidPoints = <FlSpot>[];
  List<String> dateTimeValues = <String>[];

  double xValue = 0;
  double step = 1; // original 0.05;

  late double touchedValue;

  // _ShowDevicePageState(String deviceUid, Device device) {
  //   this.deviceUid = deviceUid;
  //   this.device = device;
  // }

  // Notification Settings
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _emailFormKey = GlobalKey<FormState>();

  late TextEditingController name_controller;
  String name = '';
  // static List<String> pickerValues = ['0', '1',];
  static List<String> pickerValues = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    '47',
    '48',
    '49',
    '50',
    '51',
    '52',
    '53',
    '54',
    '55',
    '56',
    '57',
    '58',
    '59',
    '60',
    '61',
    '62',
    '63',
    '64',
    '65',
    '66',
    '67',
    '68',
    '69',
    '70',
    '71',
    '72',
    '73',
    '74',
    '75',
    '76',
    '77',
    '78',
    '79',
    '80',
    '81',
    '82',
    '83',
    '84',
    '85',
    '86',
    '87',
    '88',
    '89',
    '90',
    '91',
    '92',
    '93',
    '94',
    '95',
    '96',
    '97',
    '98',
    '99',
    '100',
  ];

  static String mSelectedTankType = Constants.TANK_TYPE_SIMPLE;
  bool mVisibilityHWL = false;
  bool mVisibilityLD = false;
  double mPercentage = -1;

  // int selectedIndex = 0;

  // bool _checked = false;
  // Color color = Colors.black45;
  // bool isSelected = false;

  // Horizontal List Wheel
  // List<Widget> items = [
  //   Center(
  //       child: Container(
  //     width: 100,
  //     height: 50,
  //     padding: new EdgeInsets.all(10.0),
  //     child: Card(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(15.0),
  //       ),
  //       color: Colors.red,
  //       elevation: 10,
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: <Widget>[
  //           const ListTile(
  //             leading: Icon(Icons.album, size: 60),
  //             title: Text('Sonu Nigam', style: TextStyle(fontSize: 30.0)),
  //             subtitle: Text('Best of Sonu Nigam Music.',
  //                 style: TextStyle(fontSize: 18.0)),
  //           ),
  //           ButtonBar(
  //             children: <Widget>[
  //               RaisedButton(
  //                 child: const Text('Play'),
  //                 onPressed: () {/* ... */},
  //               ),
  //               RaisedButton(
  //                 child: const Text('Pause'),
  //                 onPressed: () {/* ... */},
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   )),
  //   ListTile(
  //     leading: Icon(Icons.local_activity, size: 50),
  //     title: Text('Activity'),
  //     subtitle: Text('Description here'),
  //   ),
  //   ListTile(
  //     leading: Icon(Icons.local_airport, size: 50),
  //     title: Text('Airport'),
  //     subtitle: Text('Description here'),
  //   ),
  //   ListTile(
  //     leading: Icon(Icons.local_atm, size: 50),
  //     title: Text('ATM'),
  //     subtitle: Text('Description here'),
  //   ),
  //   ListTile(
  //     leading: Icon(Icons.local_bar, size: 50),
  //     title: Text('Bar'),
  //     subtitle: Text('Description here'),
  //   ),
  //   ListTile(
  //     leading: Icon(Icons.local_cafe, size: 50),
  //     title: Text('Cafe'),
  //     subtitle: Text('Description here'),
  //   ),
  //   ListTile(
  //     leading: Icon(Icons.local_car_wash, size: 50),
  //     title: Text('Car Wash'),
  //     subtitle: Text('Description here'),
  //   ),
  //   ListTile(
  //     leading: Icon(Icons.local_convenience_store, size: 50),
  //     title: Text('Heart Shaker'),
  //     subtitle: Text('Description here'),
  //   ),
  //   ListTile(
  //     leading: Icon(Icons.local_dining, size: 50),
  //     title: Text('Dining'),
  //     subtitle: Text('Description here'),
  //   ),
  //   ListTile(
  //     leading: Icon(Icons.local_drink, size: 50),
  //     title: Text('Drink'),
  //     subtitle: Text('Description here'),
  //   ),
  //   ListTile(
  //     leading: Icon(Icons.local_florist, size: 50),
  //     title: Text('Florist'),
  //     subtitle: Text('Description here'),
  //   ),
  //   ListTile(
  //     leading: Icon(Icons.local_gas_station, size: 50),
  //     title: Text('Gas Station'),
  //     subtitle: Text('Description here'),
  //   ),
  //   ListTile(
  //     leading: Icon(Icons.local_grocery_store, size: 50),
  //     title: Text('Grocery Store'),
  //     subtitle: Text('Description here'),
  //   ),
  // ];

  _ShowDevicePageState(this.deviceUid, this.device);

  @override
  void initState() {
    touchedValue = -1;

    // for (int i = 0; i < 10; i++) {
    //   data.add(Random().nextInt(100) + 1);
    // }

    // for(int i=0; i < 100;i++) {
    //   pickerValues[i] = i.toString();
    // }
    // print('pickerValues.length=${pickerValues.length}');

    super.initState();
    notification = Notify.Notification();
    mSelectedTankType = (device.wTankType != "") ? device.wTankType : Constants.TANK_TYPE_SIMPLE;

    print('mSelectedTankType=${mSelectedTankType}');

    // --------------------
    tempPoints.add(FlSpot(xValue, 0));
    humidPoints.add(FlSpot(xValue, 0));
    dateTimeValues.add('_');
    print('init state');
    print(
        'tempPoints[tempPoints.length-1].x=${tempPoints[tempPoints.length - 1].x}');
    print(
        'tempPoints[tempPoints.length-1].y=${tempPoints[tempPoints.length - 1].y}');
    print(
        'dateTimeValues[dateTimeValues.length-1]=${dateTimeValues[dateTimeValues.length - 1]}');
    print('tempPoints.length=${tempPoints.length}');
    print('dateTimeValues.length=${dateTimeValues.length}');
    xValue += step;
    // --------------------

    // Load necessary cloud database
    // may be not use
    // deviceDatabase = DeviceDatabase(device: device, user: user);
    // deviceDatabase.initState();

    name_controller = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose database.
    name_controller.dispose();
    super.dispose();
    // deviceDatabase.dispose();
  }

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              print('touchedBarSpots.length=${touchedBarSpots.length}');
              print('touchedBarSpots.toString=${touchedBarSpots.toString()}');

              return touchedBarSpots.map((barSpot) {
                print('barSpot.barIndex=${barSpot.barIndex}');
                print('barSpot.spotIndex=${barSpot.spotIndex}');
                final flSpot = barSpot;
                // if (flSpot.x == 0 || flSpot.x == 6) {
                //   return null;
                // }
                if (flSpot.x == 0) {
                  return null;
                }

                // TextAlign textAlign;
                // switch (flSpot.x.toInt()) {
                //   case 1:
                //     textAlign = TextAlign.left;
                //     break;
                //   case 5:
                //     textAlign = TextAlign.right;
                //     break;
                //   default:
                //     textAlign = TextAlign.center;
                // }
                TextAlign textAlign = TextAlign.center;
                String dateTimeString = '';
                if (barSpot.barIndex == 1) {
                  dateTimeString =
                      '${dateTimeValues[flSpot.x.toInt()].toString()}\n';
                }
                print('dateTimeString=${dateTimeString}');

                return LineTooltipItem(
                  // '${widget.weekDays[flSpot.x.toInt()]} \n',
                  // '${dateTimeString}${flSpot.y.toString()}',
                  '${dateTimeString}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: flSpot.y.toString(),
                      style: TextStyle(
                        color: Colors.grey[100],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    // const TextSpan(
                    //   text: ' k ',
                    //   style: TextStyle(
                    //     fontStyle: FontStyle.italic,
                    //     fontWeight: FontWeight.normal,
                    //   ),
                    // ),
                    // const TextSpan(
                    //   text: 'calories',
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.normal,
                    //   ),
                    // ),
                  ],
                  textAlign: textAlign,
                );
              }).toList();
            }),
        // touchCallback:
        //     (FlTouchEvent event, LineTouchResponse? lineTouch) {
        //   if (!event.isInterestedForInteractions ||
        //       lineTouch == null ||
        //       lineTouch.lineBarSpots == null) {
        //     setState(() {
        //       touchedValue = -1;
        //     });
        //     return;
        //   }
        //   final value = lineTouch.lineBarSpots![0].x;
        //
        //   if (value == 0 || value == 6) {
        //     setState(() {
        //       touchedValue = -1;
        //     });
        //     return;
        //   }
        //
        //   setState(() {
        //     touchedValue = value;
        //   });
        // }
      );

  double calculateFilledPercentage(String tankType, WeatherHistory weatherHistory) {
    double result = 0;
    switch(tankType) {
      // Simple Tank
      case Constants.TANK_TYPE_SIMPLE: {
        double height = _ShowDevicePageState.tank.wHeight; // cm
        double rangeDistance = weatherHistory.weatherData.wRangeDistance / 10; // convert mm to cm

        double filledDepth=height - rangeDistance;

        double percentage = (filledDepth / height) * 100;

        print("height=$height");
        print("rangeDistance=$rangeDistance");
        print("Filled depth=$filledDepth");
        print("percentage=$percentage");

        result = percentage;
        break;
      }
      // Horizontal Cylinder Tank
      case Constants.TANK_TYPE_HORIZONTAL_CYLINDER: {
        double diameter = _ShowDevicePageState.tank.wDiameter; // cm
        double rangeDistance = weatherHistory.weatherData.wRangeDistance / 10; // convert mm to cm

        double filledDepth=diameter - rangeDistance;

        double percentage = (filledDepth / diameter) * 100;

        print("height=$diameter");
        print("rangeDistance=$rangeDistance");
        print("Filled depth=$filledDepth");
        print("percentage=$percentage");

        result = percentage;
        break;
      }

      // Vertical Cylinder Tank
      // - ok
      case Constants.TANK_TYPE_VERTICAL_CYLINDER: {
        double height = _ShowDevicePageState.tank.wHeight; // cm
        double rangeDistance = weatherHistory.weatherData.wRangeDistance / 10; // convert mm to cm

        double filledDepth=height - rangeDistance;

        double percentage = (filledDepth / height) * 100;

        print("height=$height");
        print("rangeDistance=$rangeDistance");
        print("Filled depth=$filledDepth");

        result = percentage;
        break;
      }

      case Constants.TANK_TYPE_RECTANGLE: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume;
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_OVAL: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume;
        break;
      }

      case Constants.TANK_TYPE_VERTICAL_OVAL: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume;
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_CAPSULE: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume;
        break;
      }

      case Constants.TANK_TYPE_VERTICAL_CAPSULE: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume;
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_2_1_ELLIPTICAL: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume;
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_DISH_ENDS: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume;
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_ELLIPSE: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume;
        break;
      }
      default: {
        break;
      }
    }



    return result;
  }

  String calculateFilledDepth(String tankType, WeatherHistory weatherHistory) {
    String result = '';

    switch(tankType) {
      // Simple Tank
      case Constants.TANK_TYPE_SIMPLE: {
        double height = _ShowDevicePageState.tank.wHeight; // cm
        double rangeDistance = weatherHistory.weatherData.wRangeDistance / 10; // convert mm to cm

        double filledDepth=height - rangeDistance;

        print("height=$height");
        print("rangeDistance=$rangeDistance");
        print("Filled depth=$filledDepth");

        result = globals.formatNumber(filledDepth);
        break;
      }
      // Horizontal Cylinder Tank
      case Constants.TANK_TYPE_HORIZONTAL_CYLINDER: {
        double diameter = _ShowDevicePageState.tank.wDiameter; // height = diameter
        double radius = diameter / 2;

        double rangeDistance = weatherHistory.weatherData.wRangeDistance / 10; // convert mm to cm

        double filledHeight=diameter - rangeDistance;
        double filledDepth=(((radius - filledHeight) / radius)*(radius * radius)) - (radius - filledHeight)*sqrt((2*radius*filledHeight) - (filledHeight*filledHeight));


        print("diameter=$diameter");
        print("rangeDistance=$rangeDistance");
        print("Filled depth=$filledDepth");

        result = globals.formatNumber(filledDepth);
        break;
      }

      // Vertical Cylinder Tank
      // Filled Depth = height - rangeDistance
      case Constants.TANK_TYPE_VERTICAL_CYLINDER: {
        double height = _ShowDevicePageState.tank.wHeight; // cm
        double rangeDistance = weatherHistory.weatherData.wRangeDistance / 10; // convert mm to cm

        double filledDepth=height - rangeDistance;

        print("height=$height");
        print("rangeDistance=$rangeDistance");
        print("Filled depth=$filledDepth");

        result = globals.formatNumber(filledDepth);
        break;
      }

      case Constants.TANK_TYPE_RECTANGLE: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume.toString();
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_OVAL: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume.toString();
        break;
      }

      case Constants.TANK_TYPE_VERTICAL_OVAL: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume.toString();
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_CAPSULE: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume.toString();
        break;
      }

      case Constants.TANK_TYPE_VERTICAL_CAPSULE: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume.toString();
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_2_1_ELLIPTICAL: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume.toString();
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_DISH_ENDS: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume.toString();
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_ELLIPSE: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = volume.toString();
        break;
      }
      default: {
        break;
      }
    }
    return result;
  }

  String calculateTankVolume(String tankType) {
    String result = '';
    // dimensions default in cm

    switch(tankType) {
      // Simple Tank
      // Capacity = Volume
      case Constants.TANK_TYPE_SIMPLE: {
        double volume = _ShowDevicePageState.tank.wCapacity;
        print("Volume of the tank=$volume");

        result = globals.formatNumber(volume);
        break;
      }

      // Horizontal Cylinder Tank
      // V(tank) = πr2l
      case Constants.TANK_TYPE_HORIZONTAL_CYLINDER: {
        double length = _ShowDevicePageState.tank.wLength;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;

        double volume=Constants.pie*(radius*radius)*length;
        volume = volume / 1000; // to centimeters
        print("Volume of the cylinder=$volume");

        result = globals.formatNumber(volume);
        break;
      }
      // Vertical Cylinder Tank
      // V(tank) = πr2h
      // - ok
      case Constants.TANK_TYPE_VERTICAL_CYLINDER: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;

        double volume=Constants.pie*(radius*radius)*height;
        volume = volume / 1000; // to centimeters
        print("Volume of the cylinder=$volume");

        result = globals.formatNumber(volume);
        break;
      }

      case Constants.TANK_TYPE_RECTANGLE: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = globals.formatNumber(volume);
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_OVAL: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = globals.formatNumber(volume);

        break;
      }

      case Constants.TANK_TYPE_VERTICAL_OVAL: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = globals.formatNumber(volume);
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_CAPSULE: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = globals.formatNumber(volume);
        break;
      }

      case Constants.TANK_TYPE_VERTICAL_CAPSULE: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = globals.formatNumber(volume);
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_2_1_ELLIPTICAL: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = globals.formatNumber(volume);
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_DISH_ENDS: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = globals.formatNumber(volume);
        break;
      }

      case Constants.TANK_TYPE_HORIZONTAL_ELLIPSE: {
        double height = _ShowDevicePageState.tank.wHeight;
        double radius = _ShowDevicePageState.tank.wDiameter / 2;
        double pie=3.14285714286;
        double volume=pie*(radius*radius)*height;
        print("Volume of the cylinder=$volume");

        result = globals.formatNumber(volume);
        break;
      }
      default: {
        break;
      }
    }
    return result;
  }

  String getFilledTankPercentageImage(String tankType) {
    String result = '';
    switch (tankType) {
      case Constants.TANK_TYPE_RECTANGLE:
      case Constants.TANK_TYPE_HORIZONTAL_OVAL:
      case Constants.TANK_TYPE_VERTICAL_OVAL:
      case Constants.TANK_TYPE_HORIZONTAL_ELLIPSE:
        {

          break;
        }
      // case Constants.TANK_TYPE_VERTICAL_CYLINDER:
      //   {
      //
      //     break;
      //   }
      case Constants.TANK_TYPE_HORIZONTAL_CYLINDER:
        {

          break;
        }

      case Constants.TANK_TYPE_VERTICAL_CYLINDER:
      case Constants.TANK_TYPE_SIMPLE:
        {
          if(mPercentage <= 100 && mPercentage > 75) {
            // Constants.gFilledTankPercentageImagesMap[tankType].keys!.elementAt(0)
            // _SelectedTankType = Constants.gTankTypesMap!.keys.elementAt(index);
            result = Constants.gFilledTankPercentageImagesMap[tankType]!.values.elementAt(4);
          } else  if(mPercentage <= 75 && mPercentage > 50) {
            result = Constants.gFilledTankPercentageImagesMap[tankType]!.values.elementAt(3);
          } else  if(mPercentage <= 50 && mPercentage > 25) {
            result = Constants.gFilledTankPercentageImagesMap[tankType]!.values.elementAt(2);
          } else  if(mPercentage <= 25 && mPercentage > 0) {
            result = Constants.gFilledTankPercentageImagesMap[tankType]!.values.elementAt(1);
          } else {
            result = Constants.gFilledTankPercentageImagesMap[tankType]!.values.elementAt(0);
          }
          break;
        }

      case Constants.TANK_TYPE_HORIZONTAL_CAPSULE:
      case Constants.TANK_TYPE_VERTICAL_CAPSULE:
      case Constants.TANK_TYPE_HORIZONTAL_2_1_ELLIPTICAL:
      case Constants.TANK_TYPE_HORIZONTAL_DISH_ENDS:
        {

          break;
        }
      default:
        result = result;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    var deviceHistoryRef = FirebaseDatabase.instance
        .ref()
        .child('users/${user.uid}/devices/${device.uid}/${device.uid}_history')
        .orderByKey()
        .limitToLast(1);
    var deviceNotificationRef = FirebaseDatabase.instance
        .ref()
        .child('users/${user.uid}/devices/${device.uid}/notification')
        .orderByKey();

    var deviceTankRef = FirebaseDatabase.instance
        .ref()
        .child('users/${user.uid}/devices/${device.uid}/tank')
        .orderByKey();
    // var deviceRef = FirebaseDatabase.instance.reference().child('users/${user.uid}/devices/${device.uid}/${device.uid}_history/2021-03-31 01:32:01');
    final TextStyle? unitStyle = Theme.of(context).textTheme.headline2;
    final TextStyle? headlineStyle = Theme.of(context).textTheme.headline1;

    return StreamBuilder(
        // stream: deviceDatabase.getLatestHistory().onValue,
        stream: deviceHistoryRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapHistory) {
          if (snapHistory.hasData && !snapHistory.hasError) {
            print('=>${snapHistory.data!.snapshot.value.toString()}');
            var weatherHistory = WeatherHistory.fromJson(
                snapHistory.data!.snapshot.value as Map);
            // var weatherHistory = WeatherHistory.fromSnapshot(snap.data.snapshot);

            // Prepare value to draw live line chart
            while (tempPoints.length > limitCount) {
              tempPoints.removeAt(0);
              humidPoints.removeAt(0);
            }
            // used to be setState
            print(
                'xValue=${xValue}, weatherHistory.temperature=${weatherHistory.weatherData.temperature}|${globals.formatNumber(weatherHistory.weatherData.temperature) ?? ''}');
            print(
                'xValue=${xValue}, weatherHistory.humidity=${weatherHistory.weatherData.humidity}');
            tempPoints
                .add(FlSpot(xValue, weatherHistory.weatherData.temperature));
            humidPoints
                .add(FlSpot(xValue, weatherHistory.weatherData.humidity));
            dateTimeValues.add(weatherHistory.weatherData.uid);

            print(
                'tempPoints[tempPoints.length-1].x=${tempPoints[tempPoints.length - 1].x}');
            print(
                'tempPoints[tempPoints.length-1].y=${tempPoints[tempPoints.length - 1].y}');
            print('tempPoints.length=${tempPoints.length}');
            xValue += step;

            return StreamBuilder(
                stream: deviceTankRef.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapTank) {
                  if (snapTank.hasData && !snapTank.hasError) {
                    print('snapTank.hasData=${snapTank.hasData}');
                    print('=>${snapTank.data!.snapshot.value.toString()}');
                    if (snapTank.data!.snapshot.value != null) {
                      print('snapTank.data!.snapshot.value is not null!!');
                      var tankStream = Tank.fromJson(
                          snapTank.data!.snapshot.value as Map);
                      // Stream Tank Data from cloud
                      _ShowDevicePageState.tank.wTankType = tankStream.wTankType;
                      _ShowDevicePageState.tank.wRangeDistance = tankStream.wRangeDistance;
                      _ShowDevicePageState.tank.wFilledDepth = tankStream.wFilledDepth;
                      _ShowDevicePageState.tank.wHeight = tankStream.wHeight;
                      _ShowDevicePageState.tank.wWidth = tankStream.wWidth;
                      _ShowDevicePageState.tank.wDiameter = tankStream.wDiameter;
                      _ShowDevicePageState.tank.wSideLength = tankStream.wSideLength;
                      _ShowDevicePageState.tank.wLength = tankStream.wLength;
                      _ShowDevicePageState.tank.wCapacity = tankStream.wCapacity;

                    } else {
                      print('snapTank.data!.snapshot.value is null!!');
                    }
                    print('_ShowDevicePageState.tank.wTankType=${_ShowDevicePageState.tank.wTankType}');
                    print('_ShowDevicePageState.tank.wRangeDistance=${_ShowDevicePageState.tank.wRangeDistance}');
                    print('_ShowDevicePageState.tank.wFilledDepth=${_ShowDevicePageState.tank.wFilledDepth}');
                    print('_ShowDevicePageState.tank.wHeight=${_ShowDevicePageState.tank.wHeight}');
                    print('_ShowDevicePageState.tank.wWidth=${_ShowDevicePageState.tank.wWidth}');
                    print('_ShowDevicePageState.tank.wDiameter=${_ShowDevicePageState.tank.wDiameter}');
                    print('_ShowDevicePageState.tank.wSideLength=${_ShowDevicePageState.tank.wSideLength}');
                    print('_ShowDevicePageState.tank.wLength=${_ShowDevicePageState.tank.wLength}');
                    print('_ShowDevicePageState.tank.wCapacity=${_ShowDevicePageState.tank.wCapacity}');

                    print('_ShowDevicePageState.tankDialog.wTankType=${tankDialog.wTankType}');
                    print('_ShowDevicePageState.tankDialog.wRangeDistance=${tankDialog.wRangeDistance}');
                    print('_ShowDevicePageState.tankDialog.wFilledDepth=${tankDialog.wFilledDepth}');
                    print('_ShowDevicePageState.tankDialog.wHeight=${tankDialog.wHeight}');
                    print('_ShowDevicePageState.tankDialog.wWidth=${tankDialog.wWidth}');
                    print('_ShowDevicePageState.tankDialog.wDiameter=${tankDialog.wDiameter}');
                    print('_ShowDevicePageState.tankDialog.wSideLength=${tankDialog.wSideLength}');
                    print('_ShowDevicePageState.tankDialog.wLength=${tankDialog.wLength}');
                    print('_ShowDevicePageState.tankDialog.wCapacity=${tankDialog.wCapacity}');
                  }

                    return StreamBuilder(
                        stream: deviceNotificationRef.onValue,
                        builder:
                            (context,
                            AsyncSnapshot<DatabaseEvent> snapNotification) {
                          if (snapNotification.hasData &&
                              !snapNotification.hasError) {
                            print(
                                'snapNotification.hasData=${snapNotification
                                    .hasData}');
                            print(
                                '=>${snapNotification.data!.snapshot.value
                                    .toString()}');
                            if (snapNotification.data!.snapshot.value != null) {
                              print(
                                  'snapNotification.data!.snapshot.value is not null!!');
                              var notificationStream = Notify.Notification
                                  .fromJson(
                                  snapNotification.data!.snapshot.value as Map);

                              // Stream Notification Data from cloud
                              this.notification.notifyEmail =
                                  notificationStream.notifyEmail;
                              this.notification.notifyTempHigher =
                                  notificationStream.notifyTempHigher;
                              this.notification.notifyTempLower =
                                  notificationStream.notifyTempLower;
                              this.notification.notifyHumidHigher =
                                  notificationStream.notifyHumidHigher;
                              this.notification.notifyHumidLower =
                                  notificationStream.notifyHumidLower;
                              this.notification.isSendNotify =
                                  notificationStream.isSendNotify;
                            } else {
                              print(
                                  'snapNotification.data!.snapshot.value is null!!');
                            }

                            print(
                                'this.notification.isSendNotify=${this
                                    .notification.isSendNotify}');
                            print(
                                'this.notification.notifyEmail=${this
                                    .notification.notifyEmail}');
                            print(
                                'this.notification.notifyTempHigher=${this
                                    .notification.notifyTempHigher}');
                            print(
                                'this.notification.notifyTempLower=${this
                                    .notification.notifyTempLower}');
                            print(
                                'this.notification.notifyHumidHigher=${this
                                    .notification.notifyHumidHigher}');
                            print(
                                'this.notification.notifyHumidLower=${this
                                    .notification.notifyHumidLower}');
                          }


                          mPercentage = calculateFilledPercentage(mSelectedTankType, weatherHistory);

                          return Scaffold(
                            appBar: AppBar(
                              title: Text(
                                  '${device.name ?? device.uid} Detail'),
                            ),
                            body: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 12,
                                  ),
                                  // TempAndHumidCircularWidget(weatherHistory: weatherHistory, headlineStyle: headlineStyle, unitStyle: unitStyle),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final deviceReturn =
                                      await openTankConfigurationDialog();
                                      if (deviceReturn == null) return;

                                      setState(() {
                                        this.tankDialog.wHeight =
                                            deviceReturn.wHeight;
                                        this.tankDialog.wWidth =
                                            deviceReturn.wWidth;
                                        this.tankDialog.wDiameter =
                                            deviceReturn.wDiameter;
                                        this.tankDialog.wSideLength =
                                            deviceReturn.wSideLength;
                                        this.tankDialog.wLength =
                                            deviceReturn.wLength;
                                        // this.notification.isSendNotify = deviceReturn.isSendNotify;
                                      });
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center,
                                      // mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(child: Text('${globals.formatNumber(mPercentage)}% Full')),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center,
                                          children: [
                                            Container(
                                              width: displayWidth(context) *
                                                  0.3,
                                              child: Image(
                                                image: AssetImage(
                                                    // 'images/tanks/base_vertical_cylinder.jpg'),
                                                    // Constants.gTankImagesMap[mSelectedTankType]!),
                                                    getFilledTankPercentageImage(mSelectedTankType)),
                                              ),
                                            ),
                                            Container(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize
                                                      .min,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisSize: MainAxisSize
                                                          .min,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                            child: Text(
                                                                'Tank Volumes:')),
                                                        Container(
                                                            child: Text(
                                                                '${calculateTankVolume(mSelectedTankType)} Liters')),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize
                                                          .min,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                            child:
                                                            Text(
                                                                'Range Distance:')),
                                                        Container(child: Text(
                                                            '${globals.formatNumber(weatherHistory.weatherData.wRangeDistance / 10)}cm')),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize
                                                          .min,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                            child:
                                                            Text(
                                                                'Filled Depth(f):')),
                                                        Container(child: Text(
                                                            '${calculateFilledDepth(mSelectedTankType, weatherHistory)}cm')),
                                                      ],
                                                    ),
                                                    buildTankTypeDimensionFormDisplayOnly(mSelectedTankType),
                                                    // buildTankTypeDimensionColumn(
                                                    //     device.wTankType),
                                                  ],
                                                )),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  drawLineChart(),
                                  buildDeviceDescription(weatherHistory),
                                  buildReadingIntervalCard(context),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  // draw line chart

                                  // Notification setting
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 8,
                                      ),
                                      TextButton(
                                        child: Text('Notification'),
                                        style: TextButton.styleFrom(
                                          primary: Colors.black54,
                                          backgroundColor: Colors.white70,
                                          onSurface: Colors.grey,
                                          textStyle: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          shadowColor: Colors.limeAccent,
                                          elevation: 5,
                                        ),

                                        // style: ButtonStyle(
                                        //   foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                                        //           (Set<MaterialState> states) {
                                        //         if (states.contains(MaterialState.disabled))
                                        //           return Colors.black54;
                                        //         return null; // Defer to the widget's default.
                                        //       }),
                                        //   overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                        //           (Set<MaterialState> states) {
                                        //         if (states.contains(MaterialState.focused))
                                        //           return Colors.red;
                                        //         if (states.contains(MaterialState.hovered))
                                        //           return Colors.green;
                                        //         if (states.contains(MaterialState.pressed))
                                        //           return Colors.black54;
                                        //         return null; // Defer to the widget's default.
                                        //       }),
                                        // ),
                                        onPressed: () async {

                                          final deviceReturn =
                                          await openNotificationInputDialog();
                                          if (deviceReturn == null) return;

                                          setState(() {
                                            this.notification.notifyTempLower =
                                                deviceReturn.notifyTempLower;
                                            this.notification.notifyTempHigher =
                                                deviceReturn.notifyTempHigher;
                                            this.notification.notifyHumidLower =
                                                deviceReturn.notifyHumidLower;
                                            this.notification
                                                .notifyHumidHigher =
                                                deviceReturn.notifyHumidHigher;
                                            this.notification.notifyEmail =
                                                deviceReturn.notifyEmail;
                                            // this.notification.isSendNotify = deviceReturn.isSendNotify;
                                          });
                                        },
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      // Notification display
                                      drawNotificationDetail(),
                                    ],
                                  ),

                                  SizedBox(
                                    height: 16,
                                  ),
                                  // Row(
                                  //   children: [
                                  //     Expanded(
                                  //         child: Text(
                                  //           'Name: ',
                                  //           style: TextStyle(fontWeight: FontWeight.w600),
                                  //         ),
                                  //     ),
                                  //     const SizedBox(width: 12,),
                                  //     Text(device.notifyEmail),
                                  //   ],
                                  // )
                                ],
                              ),
                            ),
                          );
                        });
                  });
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: Text('${device.name ?? device.uid} Detail'),
                ),
                body: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.amberAccent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                    strokeWidth: 3,
                  ),
                ));
          }
        });
  }

  String getDimensionValueDisplayOnly(String dimensionType) {
    String result = '';
    switch(dimensionType) {
      case Constants.DIMENSION_TYPE_CAPACITY: {
        result = !_ShowDevicePageState.tank.wCapacity!.isNaN ? f.format(_ShowDevicePageState.tank.wCapacity!).toString() : '';
        break;
      }
      case Constants.DIMENSION_TYPE_LENGTH: {
        result = !_ShowDevicePageState.tank.wLength!.isNaN ? f.format(_ShowDevicePageState.tank.wLength!).toString() : '';
        break;
      }
      case Constants.DIMENSION_TYPE_DIAMETER: {
        result = !_ShowDevicePageState.tank.wDiameter!.isNaN ? f.format(_ShowDevicePageState.tank.wDiameter!).toString() : '';
        break;
      }
      case Constants.DIMENSION_TYPE_HEIGHT: {
        result = !_ShowDevicePageState.tank.wHeight!.isNaN ? f.format(_ShowDevicePageState.tank.wHeight!).toString() : '';
        break;
      }
      case Constants.DIMENSION_TYPE_WIDTH: {
        result = !_ShowDevicePageState.tank.wWidth!.isNaN ? f.format(_ShowDevicePageState.tank.wWidth!).toString() : '';
        break;
      }
      case Constants.DIMENSION_TYPE_SIDE_LENGTH: {
        result = !_ShowDevicePageState.tank.wSideLength!.isNaN ? f.format(_ShowDevicePageState.tank.wSideLength!).toString() : '';
        break;
      }
      default: {
        result = '';
      }
    }
    print('getDimensionValueDisplayOnly[${dimensionType}] _ShowDevicePageState.tank.wLength![${_ShowDevicePageState.tank.wLength!}] result=${result} ');
    return result;
  }

  Widget buildTankTypeDimensionFormDisplayOnly(String tankType) {
    List<Widget> list = <Widget>[];
    if (tankType == '') {
      tankType = Constants.TANK_TYPE_VERTICAL_CYLINDER;
    }

    Constants.gTankTypesMap[tankType]!.forEach((dimensionTypeName, symbol) {
      list.add(SizedBox(
        height: displayHeight(context) * 0.03, // MediaQuery.of(context).size.height / 2,

        child: Container(child: Row(

          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Text('$dimensionTypeName: ', style: TextStyle(color: Colors.black87),),
            Text(getDimensionValueDisplayOnly(dimensionTypeName), style: TextStyle(color: Colors.black87),),
            // Text('_ ', style: TextStyle(color: Colors.black87),),
            // Container(
            //   width: 100,
            //   height: 40,
            //   child: Form(
            //     key: _TankDimensionConfigState.getDimensionKey(dimensionTypeName),
            //     child: TextFormField(
            //       textAlign: TextAlign.center,
            //       style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.normal, ),
            //       initialValue: getDimensionValueDisplayOnly(dimensionTypeName),
            //       keyboardType: TextInputType.number,
            //       validator: (value) {
            //         if (value == null || value.isEmpty) {
            //           // return 'Please enter a ${dimensionTypeName} tank dimension number.';
            //           return 'Re-edit here';
            //         } else {
            //           // if (!isNumeric(value!)) {
            //           //   return 'Invalid ${dimensionTypeName} tank dimension number';
            //           // }
            //           // setState(() {
            //           //   // setDimensionValue(dimensionTypeName, value);
            //           //   print('*** ${dimensionTypeName} value=${value}');
            //           // });
            //
            //           return null;
            //         }
            //       },
            //       // controller: TextEditingController(text: this.notificationDialog.notifyEmail),
            //       autofocus: false,
            //       // decoration: InputDecoration(
            //       //   label: Text(
            //       //     'Email:',
            //       //     style: TextStyle(fontSize: 16, color: Colors.black45),
            //       //   ),
            //       //   // labelText: Text('Email:'),
            //       //   hintText: 'Enter your email address',
            //       // ),
            //       // controller: name_controller,
            //       onChanged: (value) {
            //         setState(() {
            //           setDimensionValueDisplayOnly(dimensionTypeName, value);
            //           print('+++ ${dimensionTypeName} value=${value}');
            //         });
            //       },
            //       // onSubmitted: (_) => submitNotificationSettings(),
            //     ),
            //   ),
            // ),
            Text('${symbol}', style: TextStyle(color: Colors.black87),),
          ],
        )),
      ));
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: list,
    );
  }

  void setDimensionValueDisplayOnly(String dimensionType, String value) {
    switch(dimensionType) {
      case Constants.DIMENSION_TYPE_CAPACITY: {
        widget.device.wCapacity = double.parse(value);
        tankDialog.wCapacity = double.parse(value);

        print('>> widget.device.wCapacity=${widget.device.wCapacity}');
        print('>> _ShowDevicePageState.tankDialog.wCapacity=${tankDialog.wCapacity}');
        break;
      }
      case Constants.DIMENSION_TYPE_LENGTH: {
        widget.device.wLength = double.parse(value);
        tankDialog.wLength = double.parse(value);

        print('>> widget.device.wLength=${widget.device.wLength}');
        print('>> _ShowDevicePageState.tankDialog.wLength=${tankDialog.wLength}');
        break;
      }
      case Constants.DIMENSION_TYPE_DIAMETER: {
        widget.device.wDiameter = double.parse(value);
        tankDialog.wDiameter = double.parse(value);
        print('>> widget.device.wDiameter=${widget.device.wDiameter}');
        print('>> _ShowDevicePageState.tank.wDiameter=${tankDialog.wDiameter}');
        break;
      }
      case Constants.DIMENSION_TYPE_HEIGHT: {
        widget.device.wHeight = double.parse(value);
        tankDialog.wHeight = double.parse(value);
        print('>> widget.device.wHeight=${widget.device.wHeight}');
        print('>> _ShowDevicePageState.tank.wHeight=${tankDialog.wHeight}');
        break;
      }
      case Constants.DIMENSION_TYPE_WIDTH: {
        widget.device.wWidth = double.parse(value);
        tankDialog.wWidth = double.parse(value);
        print('>> widget.device.wWidth=${widget.device.wWidth}');
        print('>> _ShowDevicePageState.tank.wWidth=${tankDialog.wWidth}');
        break;
      }
      case Constants.DIMENSION_TYPE_SIDE_LENGTH: {
        widget.device.wSideLength = double.parse(value);
        tankDialog.wSideLength = double.parse(value);
        print('>> widget.device.wSideLength=${widget.device.wSideLength}');
        print('>> _ShowDevicePageState.tank.wSideLength=${tankDialog.wSideLength}');
        break;
      }
      default: {
        break;
      }
    }
  }

  List<Widget> buildTankTypesConfiguration() {
    List<Widget> results = [];
    Constants.gTankTypesMap!.forEach((name, symbol) {
      results.add(Container(
          width: displayWidth(context) * 0.8,
          child: Card(
            color: Colors.black12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: displayWidth(context) * 0.2,
                    child: Image(
                      image: AssetImage(
                          Constants.gTankImagesMap[name]!),
                          // 'images/tanks/base_vertical_cylinder.jpg'),
                    ),
                  ),
                  Text('$name'),
                ],
              ))

      )
      );
    });
    return results;
  }

  Widget buildTankTypeDimensionColumn(String tankType) {
    List<Widget> list = <Widget>[];
    if (tankType == '') {
      tankType = Constants.TANK_TYPE_VERTICAL_CYLINDER;
    }

    Constants.gTankTypesMap[tankType]!.forEach((name, symbol) {
      list.add(Container(child: Text('${name}: 200${symbol}')));
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: list,
    );
  }



  Column buildDeviceDescription(WeatherHistory weatherHistory) {
    return Column(
      children: [
        // Center(
        //   child: Container(
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       mainAxisAlignment: MainAxisAlignment.end,
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: [
        //         Text('Device ', style: TextStyle( fontSize: 14, color: Colors.black45),),
        //         Text('${device.name ?? device.uid}', style: TextStyle( fontSize: 14, color: Colors.black87),),
        //         Text(' Detail', style: TextStyle( fontSize: 14, color: Colors.black45),),
        //       ],
        //     ),
        //   ),
        // ),
        Center(
          child: Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'latest when ',
                  style: TextStyle(fontSize: 14, color: Colors.black45),
                ),
                Text(
                  '${weatherHistory?.weatherData?.uid ?? 'no data'}',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Container(
            // child: Text('battery voltage ${weatherHistory?.weatherData?.readVoltage.toStringAsFixed(weatherHistory?.weatherData?.readVoltage.truncateToDouble() == weatherHistory?.weatherData?.readVoltage ? 0 : 2) ?? 'no data'} volts'),
            // child: Text('battery voltage ${globals.formatNumber(weatherHistory?.weatherData?.readVoltage) ?? 'no data'} volts'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'battery voltage ',
                  style: TextStyle(fontSize: 14, color: Colors.black45),
                ),
                Text(
                  '${weatherHistory?.weatherData?.readVoltage ?? 'no data'}',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  ' volts',
                  style: TextStyle(fontSize: 14, color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LineChartBarData tempLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: FlDotData(
        show: false,
      ),
      gradient: LinearGradient(
          colors: [tempColor.withOpacity(0), tempColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.1, 1.0]),
      barWidth: 4,
      isCurved: false,
      // isStrokeCapRound: true,
    );
  }

  LineChartBarData humidLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: FlDotData(
        show: false,
      ),
      gradient: LinearGradient(
          colors: [humidColor.withOpacity(0), humidColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.1, 1.0]),
      barWidth: 4,
      isCurved: false,
    );
  }

  Card buildWorkingModeCard(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: Column(
                children: [
                  IconButton(
                    color: burstePressed ? Colors.lightGreen : Colors.grey,
                    icon: const Icon(Icons.autorenew),
                    tooltip:
                        'Continue read sensor value every short time period',
                    onPressed: () {
                      setState(() {
                        burstePressed = !burstePressed;
                        requestPressed = false;
                        pollingPressed = false;
                        offlinePressed = false;
                      });
                    },
                  ),
                  Text(
                    'Burst',
                    style: burstePressed
                        ? Theme.of(context).textTheme.subtitle2
                        : Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  IconButton(
                    color: requestPressed ? Colors.lightGreen : Colors.grey,
                    icon: const Icon(Icons.wifi_calling),
                    tooltip: 'Read sensor by request',
                    onPressed: () {
                      setState(() {
                        burstePressed = false;
                        requestPressed = !requestPressed;
                        pollingPressed = false;
                        offlinePressed = false;
                      });
                    },
                  ),
                  Text(
                    'Request',
                    style: requestPressed
                        ? Theme.of(context).textTheme.subtitle2
                        : Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  IconButton(
                    color: pollingPressed ? Colors.lightGreen : Colors.grey,
                    icon: const Icon(Icons.battery_alert),
                    tooltip:
                        'Read sensor value every long time period to safe battery life time',
                    onPressed: () {
                      setState(() {
                        burstePressed = false;
                        requestPressed = false;
                        pollingPressed = !pollingPressed;
                        offlinePressed = false;
                      });
                    },
                  ),
                  Text(
                    'Polling',
                    style: pollingPressed
                        ? Theme.of(context).textTheme.subtitle2
                        : Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  IconButton(
                    color: offlinePressed ? Colors.lightGreen : Colors.grey,
                    icon: const Icon(Icons.wifi_off),
                    tooltip:
                        'Save read sensor value in "the Node" local memory',
                    onPressed: () {
                      setState(() {
                        burstePressed = false;
                        requestPressed = false;
                        pollingPressed = false;
                        offlinePressed = !offlinePressed;
                      });
                    },
                  ),
                  Text(
                    'Offline',
                    style: offlinePressed
                        ? Theme.of(context).textTheme.subtitle2
                        : Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Card buildReadingIntervalCard(BuildContext context) {
    // draw card
    final TextStyle? inactiveStyle = Theme.of(context).textTheme.headline5;
    final TextStyle? activeStyle = Theme.of(context).textTheme.headline6;
    return Card(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = !sec10Pressed;
                  sec30Pressed = false;
                  min1Pressed = false;
                  min5Pressed = false;
                  min30Pressed = false;
                  hour1Pressed = false;
                  hour2Pressed = false;
                  hour3Pressed = false;
                  hour4Pressed = false;

                  selectedInterval = 10000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text(
                      '10',
                      style: sec10Pressed ? activeStyle : inactiveStyle,
                    ),
                    Text(
                      'sec',
                      style: sec10Pressed
                          ? Theme.of(context).textTheme.subtitle2
                          : Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = !sec30Pressed;
                  min1Pressed = false;
                  min5Pressed = false;
                  min30Pressed = false;
                  hour1Pressed = false;
                  hour2Pressed = false;
                  hour3Pressed = false;
                  hour4Pressed = false;

                  selectedInterval = 30000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text(
                      '30',
                      style: sec30Pressed ? activeStyle : inactiveStyle,
                    ),
                    Text(
                      'sec',
                      style: sec30Pressed
                          ? Theme.of(context).textTheme.subtitle2
                          : Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = !min1Pressed;
                  min5Pressed = false;
                  min30Pressed = false;
                  hour1Pressed = false;
                  hour2Pressed = false;
                  hour3Pressed = false;
                  hour4Pressed = false;

                  selectedInterval = 60000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text(
                      '1',
                      style: min1Pressed ? activeStyle : inactiveStyle,
                    ),
                    Text(
                      'min',
                      style: min1Pressed
                          ? Theme.of(context).textTheme.subtitle2
                          : Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = false;
                  min5Pressed = !min5Pressed;
                  min30Pressed = false;
                  hour1Pressed = false;
                  hour2Pressed = false;
                  hour3Pressed = false;
                  hour4Pressed = false;

                  selectedInterval = 300000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text(
                      '5',
                      style: min5Pressed ? activeStyle : inactiveStyle,
                    ),
                    Text(
                      'min',
                      style: min5Pressed
                          ? Theme.of(context).textTheme.subtitle2
                          : Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = false;
                  min5Pressed = false;
                  min30Pressed = !min30Pressed;
                  hour1Pressed = false;
                  hour2Pressed = false;
                  hour3Pressed = false;
                  hour4Pressed = false;

                  selectedInterval = 1800000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text(
                      '30',
                      style: min30Pressed ? activeStyle : inactiveStyle,
                    ),
                    Text(
                      'min',
                      style: min30Pressed
                          ? Theme.of(context).textTheme.subtitle2
                          : Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = false;
                  min5Pressed = false;
                  min30Pressed = false;
                  hour1Pressed = !hour1Pressed;
                  hour2Pressed = false;
                  hour3Pressed = false;
                  hour4Pressed = false;

                  selectedInterval = 3600000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text(
                      '1',
                      style: hour1Pressed ? activeStyle : inactiveStyle,
                    ),
                    Text(
                      'hour',
                      style: hour1Pressed
                          ? Theme.of(context).textTheme.subtitle2
                          : Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = false;
                  min5Pressed = false;
                  min30Pressed = false;
                  hour1Pressed = false;
                  hour2Pressed = !hour2Pressed;
                  hour3Pressed = false;
                  hour4Pressed = false;

                  selectedInterval = 7200000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text(
                      '2',
                      style: hour2Pressed ? activeStyle : inactiveStyle,
                    ),
                    Text(
                      'hour',
                      style: hour2Pressed
                          ? Theme.of(context).textTheme.subtitle2
                          : Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = false;
                  min5Pressed = false;
                  min30Pressed = false;
                  hour1Pressed = false;
                  hour2Pressed = false;
                  hour3Pressed = !hour3Pressed;
                  hour4Pressed = false;

                  selectedInterval = 10800000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text(
                      '3',
                      style: hour3Pressed ? activeStyle : inactiveStyle,
                    ),
                    Text(
                      'hour',
                      style: hour3Pressed
                          ? Theme.of(context).textTheme.subtitle2
                          : Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = false;
                  min5Pressed = false;
                  min30Pressed = false;
                  hour1Pressed = false;
                  hour2Pressed = false;
                  hour3Pressed = false;
                  hour4Pressed = !hour4Pressed;

                  selectedInterval = 14400000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text(
                      '4',
                      style: hour4Pressed ? activeStyle : inactiveStyle,
                    ),
                    Text(
                      'hour',
                      style: hour4Pressed
                          ? Theme.of(context).textTheme.subtitle2
                          : Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * First contact to "the Node" to pass reading interval value
   */
  // Future<http.Response> updateReadingInterval() async {
  Future<void> updateReadingInterval() async {
    // update reading interval in cloud database
    // deviceDatabase.updateDevice(device);
    print(
        'update reading interval in cloud database - users/${user.uid}/devices/${device.uid}');
    var deviceRef = FirebaseDatabase.instance
        .ref()
        .child('users/${user.uid}/devices/${device.uid}')
        .update({
          // 'name':  device.name,
          'readingInterval': selectedInterval,
        })
        .onError((error, stackTrace) =>
            print('updateNotificationSettings error=${error.toString()}'))
        .whenComplete(() {
          print('updated notification settings success.');
          showDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                    title: Text("Update Successfully"),
                    content: Text(
                        "Update reading interval settings is successfully."),
                    actions: [
                      CupertinoDialogAction(
                        child: Text("OK"),
                        onPressed: () {
                          // Navigator.pop(context);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
              barrierDismissible: false);
        });

    // // Hostname on device detail page
    // String hostName = '';
    // String hostIp = '';
    // String macAddressWithoutColon = hostName = device.uid.replaceAll(':', '');
    // hostName = '${Constants.of(context)!.DEFAULT_THE_NODE_DNS}${macAddressWithoutColon.toLowerCase()}.local';
    // hostIp = '${device.localip}:80';
    // print('hostName=${hostName}');
    // print('host local ip address=${hostIp}');
    // print('Device reading interval[${selectedInterval}] - setting...');
    // var url =
    // // Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});
    // //   Uri.http(hostName, '/setting', {'interval': selectedInterval.toString()});
    // // Change to use local ip address of each device to be send request to update device setting from "theApp".
    //   Uri.http(hostIp, '/setting', {'interval': selectedInterval.toString()});
    //
    // // Await the http get response, then decode the json-formatted response.
    // final response = await http.get(url);
    // print("status code =${response.statusCode}");
    // if (response.statusCode == 200) {
    //   print('Device reading interval[${selectedInterval}] - setting is ok!!');
    // } else {
    //   print('Device reading interval[${selectedInterval}] - setting is not ok!!');
    //   throw Exception('Failed to do wifi settings');
    // }

    // return response;
  }

  Future<void> updateTankDimensionSettingSubTank() async {
    print(
        'update tank dimension settings in cloud database - users/${user.uid}/devices/${device.uid}/tank');
    var deviceTankRef = FirebaseDatabase.instance
        .ref()
        .child('users/${user.uid}/devices/${device.uid}/tank')
        .update({
      // 'name':  device.name,
      'wTankType': (mSelectedTankType == '')
          ? ''
          : mSelectedTankType,
      'wHeight': (tankDialog.wHeight == 0)
          ? _ShowDevicePageState.tank.wHeight
          : tankDialog.wHeight,
      'wWidth': (tankDialog.wWidth == 0)
          ? _ShowDevicePageState.tank.wWidth
          : tankDialog.wWidth,
      'wDiameter': (tankDialog.wDiameter == 0)
          ? _ShowDevicePageState.tank.wDiameter
          : tankDialog.wDiameter,
      'wSideLength': (tankDialog.wSideLength == 0)
          ? _ShowDevicePageState.tank.wSideLength
          : tankDialog.wSideLength,
      'wLength': (tankDialog.wLength == 0)
          ? _ShowDevicePageState.tank.wLength
          : tankDialog.wLength,
      'wCapacity': (tankDialog.wCapacity == 0)
          ? _ShowDevicePageState.tank.wCapacity
          : tankDialog.wCapacity,
      'wFilledDepth': (tankDialog.wFilledDepth == 0)
          ? _ShowDevicePageState.tank.wFilledDepth
          : tankDialog.wFilledDepth,
    })
        .onError((error, stackTrace) {
      print('updateTankDimensionSettings error=${error.toString()}');
      showDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Text("Update Error"),
            content:
            Text("Update tank dimension settings is failed."),
            actions: [
              CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          barrierDismissible: false
      );
    }
    )
        .whenComplete(() {
      print('updated tank dimension settings success.');
      showDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Text("Update Successfully"),
            content:
            Text("Update tank dimension settings is successfully."),
            actions: [
              CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop();
                  // setState(() {
                  //   device.wTankType =
                  // });
                },
              ),
            ],
          ),
          barrierDismissible: false
      );
    }
    );
  }

  /**
   * "the Node" to save tank dimension values
   */
  Future<void> updateTankDimensionSettings() async {
    // update tank dimension settings in cloud database
    print(
        'update tank dimension settings in cloud database - users/${user.uid}/devices/${device.uid}');

    print('>>>>_ShowDevicePageState.tank.wLength=${_ShowDevicePageState.tank.wLength}');
    print('>>>>_ShowDevicePageState.tankDialog.wLength=${tankDialog.wLength}');
    var deviceRef = FirebaseDatabase.instance
        .ref()
        .child('users/${user.uid}/devices/${device.uid}')
        .update({
      // 'name':  device.name,
      'wTankType': (mSelectedTankType == '')
          ? ''
          : mSelectedTankType,
      'wHeight': (tankDialog.wHeight == 0)
          ? _ShowDevicePageState.tank.wHeight
          : tankDialog.wHeight,
      'wWidth': (tankDialog.wWidth == 0)
          ? _ShowDevicePageState.tank.wWidth
          : tankDialog.wWidth,
      'wDiameter': (tankDialog.wDiameter == 0)
          ? _ShowDevicePageState.tank.wDiameter
          : tankDialog.wDiameter,
      'wSideLength': (tankDialog.wSideLength == 0)
          ? _ShowDevicePageState.tank.wSideLength
          : tankDialog.wSideLength,
      'wLength': (tankDialog.wLength == 0)
          ? _ShowDevicePageState.tank.wLength
          : tankDialog.wLength,
      'wCapacity': (tankDialog.wCapacity == 0)
          ? _ShowDevicePageState.tank.wCapacity
          : tankDialog.wCapacity,
      'wFilledDepth': (tankDialog.wFilledDepth == 0)
          ? _ShowDevicePageState.tank.wFilledDepth
          : tankDialog.wFilledDepth,
    })
        .onError((error, stackTrace) {
            print('updateTankDimensionSettings error=${error.toString()}');
            showDialog(
                context: context,
                builder: (_) => CupertinoAlertDialog(
                  title: Text("Update Error"),
                  content:
                  Text("Update tank dimension settings is failed."),
                  actions: [
                    CupertinoDialogAction(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                barrierDismissible: false
            );
          }
        )
        .whenComplete(() {
          print('updated tank dimension settings at device root success.');
          updateTankDimensionSettingSubTank();
          // showDialog(
          //     context: context,
          //     builder: (_) => CupertinoAlertDialog(
          //       title: Text("Update Successfully"),
          //       content:
          //       Text("Update tank dimension settings is successfully."),
          //       actions: [
          //         CupertinoDialogAction(
          //           child: Text("OK"),
          //           onPressed: () {
          //             Navigator.pop(context);
          //             Navigator.of(context).pop();
          //           },
          //         ),
          //       ],
          //     ),
          //     barrierDismissible: false
          // );
        }
        );
    return;
  }

  /**
   * "the Node" to save notification values
   */
  Future<void> updateNotificationSettings() async {
    // update notification settings in cloud database
    print(
        'update notification settings in cloud database - users/${user.uid}/devices/${device.uid}/notification');
    var deviceRef = FirebaseDatabase.instance
        .ref()
        .child('users/${user.uid}/devices/${device.uid}/notification')
        .update({
          // 'name':  device.name,
          'notifyHumidLower': (this.notificationDialog.notifyHumidLower == 0)
              ? this.notification.notifyHumidLower
              : this.notificationDialog.notifyHumidLower,
          'notifyHumidHigher': (this.notificationDialog.notifyHumidHigher == 0)
              ? this.notification.notifyHumidHigher
              : this.notificationDialog.notifyHumidHigher,
          'notifyTempLower': (this.notificationDialog.notifyTempLower == 0)
              ? this.notification.notifyTempLower
              : this.notificationDialog.notifyTempLower,
          'notifyTempHigher': (this.notificationDialog.notifyTempHigher == 0)
              ? this.notification.notifyTempHigher
              : this.notificationDialog.notifyTempHigher,
          'notifyEmail': this.notificationDialog.notifyEmail,
          'isSendNotify': this.notification.isSendNotify,
        })
        .onError((error, stackTrace) =>
            print('updateNotificationSettings error=${error.toString()}'))
        .whenComplete(() {
          print('updated notification settings success.');
          showDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                    title: Text("Update Successfully"),
                    content:
                        Text("Update notification settings is successfully."),
                    actions: [
                      CupertinoDialogAction(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
              barrierDismissible: false);
        });

    return;
  }

  Future<List<WeatherData>> getLast10Histories() async {
    final onceHistoriesSnapshot = await FirebaseDatabase.instance
        .ref()
        .child('users/${user.uid}/devices/${device.uid}/${device.uid}_history')
        .orderByKey()
        .limitToLast(10)
        .get();

    print(onceHistoriesSnapshot); // to debug and see if data is returned

    List<WeatherData> histories = [];

    if (onceHistoriesSnapshot.exists) {
      histories.clear();
      tempPoints.clear();
      humidPoints.clear();
      dateTimeValues.clear();

      print(onceHistoriesSnapshot.value);
      Map<dynamic, dynamic>? values = onceHistoriesSnapshot.value as Map?;

      values!.forEach((key, weatherValues) {
        print('key=${key}');
        print('temperature=[${weatherValues['temperature']}]');

        tempPoints.add(FlSpot(
            xValue, globals.parseDouble(weatherValues['temperature'] ?? 0)));
        humidPoints.add(FlSpot(
            xValue, globals.parseDouble(weatherValues['humidity'] ?? 0)));
        dateTimeValues.add(weatherValues['uid'] ?? '');

        xValue += step;

        histories.add(WeatherData(
          uid: weatherValues['uid'] ?? '',
          deviceId: weatherValues['deviceId'] ?? '',
          humidity: globals.parseDouble(weatherValues['humidity'] ?? 0),
          temperature: globals.parseDouble(weatherValues['temperature'] ?? 0),
          readVoltage: globals.parseDouble(weatherValues['readVoltage'] ?? 0),
          // add TOF10120(Water level) sensor data xxz
          wRangeDistance: globals.parseDouble(weatherValues['wRangeDistance'] ?? 0),
          wFilledDepth: globals.parseDouble(weatherValues['wFilledDepth'] ?? 0),
          wCapacity: globals.parseDouble(weatherValues['wCapacity'] ?? 0),
          wHeight: globals.parseDouble(weatherValues['temperature'] ?? 0),
          wWidth: globals.parseDouble(weatherValues['temperature'] ?? 0),
          wDiameter: globals.parseDouble(weatherValues['temperature'] ?? 0),
          wSideLength: globals.parseDouble(weatherValues['temperature'] ?? 0),
          wLength: globals.parseDouble(weatherValues['temperature'] ?? 0),

        ));
      });

      tempPoints.sort((a, b) => a.x.compareTo(b.x));
      humidPoints.sort((a, b) => a.x.compareTo(b.x));
      dateTimeValues.sort((a, b) => a.compareTo(b));
    } else {
      histories.clear();
      tempPoints.add(FlSpot(xValue, 0));
      humidPoints.add(FlSpot(xValue, 0));
      dateTimeValues.add('_');
      print('No data available.');
    }

    return histories;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    getLast10Histories();
    switch (device.readingInterval) {
      case Constants.INTERVAL_SECOND_10:
        {
          setState(() {
            sec10Pressed = true;
            sec30Pressed = false;
            min1Pressed = false;
            min5Pressed = false;
            min30Pressed = false;
            hour1Pressed = false;
            hour2Pressed = false;
            hour3Pressed = false;
            hour4Pressed = false;
          });
        }
        break;

      case Constants.INTERVAL_SECOND_30:
        {
          setState(() {
            sec10Pressed = false;
            sec30Pressed = true;
            min1Pressed = false;
            min5Pressed = false;
            min30Pressed = false;
            hour1Pressed = false;
            hour2Pressed = false;
            hour3Pressed = false;
            hour4Pressed = false;
          });
        }
        break;

      case Constants.INTERVAL_MINUTE_1:
        {
          setState(() {
            sec10Pressed = false;
            sec30Pressed = false;
            min1Pressed = true;
            min5Pressed = false;
            min30Pressed = false;
            hour1Pressed = false;
            hour2Pressed = false;
            hour3Pressed = false;
            hour4Pressed = false;
          });
        }
        break;

      case Constants.INTERVAL_MINUTE_5:
        {
          setState(() {
            sec10Pressed = false;
            sec30Pressed = false;
            min1Pressed = false;
            min5Pressed = true;
            min30Pressed = false;
            hour1Pressed = false;
            hour2Pressed = false;
            hour3Pressed = false;
            hour4Pressed = false;
          });
        }
        break;

      case Constants.INTERVAL_MINUTE_30:
        {
          setState(() {
            sec10Pressed = false;
            sec30Pressed = false;
            min1Pressed = false;
            min5Pressed = false;
            min30Pressed = true;
            hour1Pressed = false;
            hour2Pressed = false;
            hour3Pressed = false;
            hour4Pressed = false;
          });
        }
        break;

      case Constants.INTERVAL_HOUR_1:
        {
          setState(() {
            sec10Pressed = false;
            sec30Pressed = false;
            min1Pressed = false;
            min5Pressed = false;
            min30Pressed = false;
            hour1Pressed = true;
            hour2Pressed = false;
            hour3Pressed = false;
            hour4Pressed = false;
          });
        }
        break;

      case Constants.INTERVAL_HOUR_2:
        {
          setState(() {
            sec10Pressed = false;
            sec30Pressed = false;
            min1Pressed = false;
            min5Pressed = false;
            min30Pressed = false;
            hour1Pressed = false;
            hour2Pressed = true;
            hour3Pressed = false;
            hour4Pressed = false;
          });
        }
        break;

      case Constants.INTERVAL_HOUR_3:
        {
          setState(() {
            sec10Pressed = false;
            sec30Pressed = false;
            min1Pressed = false;
            min5Pressed = false;
            min30Pressed = false;
            hour1Pressed = false;
            hour2Pressed = false;
            hour3Pressed = true;
            hour4Pressed = false;
          });
        }
        break;

      case Constants.INTERVAL_HOUR_4:
        {
          setState(() {
            sec10Pressed = false;
            sec30Pressed = false;
            min1Pressed = false;
            min5Pressed = false;
            min30Pressed = false;
            hour1Pressed = false;
            hour2Pressed = false;
            hour3Pressed = false;
            hour4Pressed = true;
          });
        }
        break;

      default:
        {
          setState(() {
            sec10Pressed = false;
            sec30Pressed = true;
            min1Pressed = false;
            min5Pressed = false;
            min30Pressed = false;
            hour1Pressed = false;
            hour2Pressed = false;
            hour3Pressed = false;
            hour4Pressed = false;
          });
        }
        break;
    }
    // switch(device.mode) {
    //   case Constants.MODE_BURST: {
    //     burstePressed = true;
    //     requestPressed = false;
    //     pollingPressed = false;
    //     offlinePressed = false;
    //   }
    //   break;
    //
    //   case Constants.MODE_REQUEST: {
    //     burstePressed = false;
    //     requestPressed = true;
    //     pollingPressed = false;
    //     offlinePressed = false;
    //   }
    //   break;
    //
    //   case Constants.MODE_POLLING: {
    //     burstePressed = false;
    //     requestPressed = false;
    //     pollingPressed = true;
    //     offlinePressed = false;
    //   }
    //   break;
    //
    //   case Constants.MODE_OFFLINE: {
    //     burstePressed = false;
    //     requestPressed = false;
    //     pollingPressed = false;
    //     offlinePressed = true;
    //   }
    //   break;
    //
    //   default: {
    //     burstePressed = false;
    //     requestPressed = false;
    //     pollingPressed = false;
    //     offlinePressed = false;
    //   }
    //   break;
    //
    // }
  }

  bool verifyDimensionValue(String tankType) {
    bool result = false;
    switch (tankType) {
      case Constants.TANK_TYPE_RECTANGLE:
      case Constants.TANK_TYPE_HORIZONTAL_OVAL:
      case Constants.TANK_TYPE_VERTICAL_OVAL:
      case Constants.TANK_TYPE_HORIZONTAL_ELLIPSE:
        {
          if (_lengthFormKey.currentState!.validate() &&
              _heightFormKey.currentState!.validate() &&
              _widthFormKey.currentState!.validate()) {
            result = true;
          }
          break;
        }
      case Constants.TANK_TYPE_VERTICAL_CYLINDER:
        {
          if (_heightFormKey.currentState!.validate() &&
              _diameterFormKey.currentState!.validate()) {
            result = true;
          }
          break;
        }
      case Constants.TANK_TYPE_HORIZONTAL_CYLINDER:
        {
          if (_lengthFormKey.currentState!.validate() &&
              _diameterFormKey.currentState!.validate()) {
            result = true;
          }
          break;
        }

      case Constants.TANK_TYPE_SIMPLE:
        {
          if (_heightFormKey.currentState!.validate() &&
              _capacityFormKey.currentState!.validate()) {
            result = true;
          }
          break;
        }

      case Constants.TANK_TYPE_HORIZONTAL_CAPSULE:
      case Constants.TANK_TYPE_VERTICAL_CAPSULE:
      case Constants.TANK_TYPE_HORIZONTAL_2_1_ELLIPTICAL:
      case Constants.TANK_TYPE_HORIZONTAL_DISH_ENDS:
        {
          if (_diameterFormKey.currentState!.validate() &&
              _sideLengthFormKey.currentState!.validate()) {
            result = true;
          }
          break;
        }
      default:
        result = false;
    }

    print('verifyDimensionValue[${tankType}]] result=${result} ');
    return result;
  }

  Future<Tank?> openTankConfigurationDialog() {
    return showDialog<Tank>(
      context: context,
      builder: (context) =>
          AlertDialog(
            insetPadding: EdgeInsets.only(
              top: 2.0,
              left: 4.0,
              right: 4.0,
            ),
            title: Container(
                alignment: Alignment.topCenter,
                child: Text('Tank Configuration')),
            content: Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: EdgeInsets.symmetric(),
                color: Colors.limeAccent,
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TankDimensionConfig(device: this.device, selectedTankType: mSelectedTankType,
                        tankDialog: this.tankDialog,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('CLOSE')),
              TextButton(
                // onPressed: submitNotificationSettings,
                  onPressed: () {
                    print('>>>Call verifyDimensionValue(${mSelectedTankType}');
                    if(verifyDimensionValue(mSelectedTankType)) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      updateTankDimensionSettings();

                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text('Updated Data')),
                      // );

                    } else {
                      showDialog(
                          context: context,
                          builder: (_) =>
                              CupertinoAlertDialog(
                                title: Text("Invalid Tank Dimension Config Value"),
                                content: Text(
                                    "Please enter the correct number format of the tank dimension.\ And re-submit again."),
                                actions: [
                                  CupertinoDialogAction(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                          barrierDismissible: false);
                    }
                  },
                  child: Text('SUBMIT')),
            ],
          ),
    );
  }

  // Widget _buildListItem(BuildContext context, int index) {
  //   if (index == data.length)
  //     return Center(child: CircularProgressIndicator(),);
  //
  //   //horizontal
  //   return Container(
  //     width: 150,
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: <Widget>[
  //         Container(
  //           height: 200,
  //           width: 150,
  //           color: Colors.lightBlueAccent,
  //           child: Text("i:$index\n${data[index]}"),
  //         )
  //       ],
  //     ),
  //   );
  // }
  //
  // void _onItemFocus(int index) {
  //   print(index);
  //   setState(() {
  //     _focusedIndex = index;
  //   });
  // }

  Future<Notify.Notification?> openNotificationInputDialog() =>
      showDialog<Notify.Notification>(
        context: context,
        builder: (context) => AlertDialog(
          insetPadding: EdgeInsets.only(
            top: 2.0,
            left: 4.0,
            right: 4.0,
          ),
          title: Container(
              alignment: Alignment.topCenter, child: Text('Notification')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    padding: EdgeInsets.only(left: 0.0, right: 0.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26)),
                    child: CheckboxListTile(
                      title: Text(
                        'Send notification email',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      subtitle: Text(
                        'Enable send the notification email when it meet condition.',
                        style: TextStyle(fontSize: 12, color: Colors.black38),
                      ),
                      secondary: Icon(Icons.mail_outline),
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: this.notification.isSendNotify,
                      selected: this.notification.isSendNotify,
                      // value: _checked,
                      onChanged: (bool? value) {
                        setState(() {
                          this.notification.isSendNotify = value!;
                          print('check value=${value}');
                        });
                      },
                      activeColor: Colors.lightGreen,
                      checkColor: Colors.yellow,
                    ),
                  );
                }),

                // Text('will send to', style: TextStyle( fontSize: 16, color: Colors.black45),),
                Form(
                  key: _emailFormKey,
                  child: TextFormField(
                    initialValue: this.notification.notifyEmail,
                    keyboardType: TextInputType.emailAddress,
                    // validator: (val) => !isEmail(val!) ? 'Invalid Email' : null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      } else {
                        if (!isEmail(value!)) {
                          return 'Invalid Email';
                        }
                        setState(() {
                          this.notificationDialog.notifyEmail = value;
                        });

                        return null;
                      }
                    },
                    autofocus: false,
                    decoration: InputDecoration(
                      label: Text(
                        'Email:',
                        style: TextStyle(fontSize: 16, color: Colors.black45),
                      ),
                      // labelText: Text('Email:'),
                      hintText: 'Enter your email address',
                    ),
                    // controller: name_controller,
                    // onChanged: (value) {
                    //   setState(() {
                    //     this.device.notifyEmail = value;
                    //   });
                    // },
                    // onSubmitted: (_) => submitNotificationSettings(),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  'when',
                  style: TextStyle(fontSize: 16, color: Colors.black45),
                ),
                SizedBox(
                  height: 16,
                ),
                buildTemperatureNotifyDialog(),
                SizedBox(
                  height: 8,
                ),
                buildHumidityNotifyDialog(),

                // buildCustomPicker(),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('CLOSE')),
            TextButton(
                // onPressed: submitNotificationSettings,
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_emailFormKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    updateNotificationSettings();

                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text('Updated Data')),
                    // );

                  } else {
                    showDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                              title: Text("Invalid Email"),
                              content: Text(
                                  "Please enter the correct email format.\ And submit again."),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                        barrierDismissible: false);
                  }
                },
                child: Text('SUBMIT')),
          ],
        ),
      );

  void submitNotificationSettings() {
    // Navigator.of(context).pop(name_controller.text);
    //
    // name_controller.clear();
  }

  // Widget buildCustomPicker() => SizedBox(
  //   height: 300,
  //   child: CupertinoPicker(
  //     itemExtent: 64,
  //     diameterRatio: 0.7,
  //     looping: true,
  //     onSelectedItemChanged: (index) => setState(() => this.selectedIndex = index),
  //     // selectionOverlay: Container(),
  //     selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
  //       background: Colors.pink.withOpacity(0.12),
  //     ),
  //     children: Utils.modelBuilder<String>(
  //       pickerValues,
  //           (index, value) {
  //         final isSelected = this.selectedIndex == index;
  //         final color = isSelected ? Colors.pink : Colors.black;
  //
  //         return Center(
  //           child: Text(
  //             value,
  //             style: TextStyle(color: color, fontSize: 24),
  //           ),
  //         );
  //       },
  //     ),
  //   ),
  // );

  Widget buildTemperatureNumberPicker(int pickerType) => SizedBox(
        height: 80,
        width: 50,
        child: CupertinoPicker(
          // backgroundColor: Colors.limeAccent,
          itemExtent: 48,
          diameterRatio: 1.5,
          looping: true,
          useMagnifier: true,
          magnification: 1.2,
          scrollController: FixedExtentScrollController(
              initialItem: initScrollIndex(pickerType)),
          onSelectedItemChanged: (index) => setState(() {
            switch (pickerType) {
              case Constants.TEMP_LOWER:
                {
                  this.notificationDialog.notifyTempLower =
                      double.parse(pickerValues[index].toString());
                  break;
                }
              case Constants.TEMP_HIGHER:
                {
                  this.notificationDialog.notifyTempHigher =
                      double.parse(pickerValues[index].toString());
                  break;
                }
              default:
                {
                  this.notificationDialog.notifyTempLower =
                      double.parse(pickerValues[index].toString());
                  break;
                }
            }
          }),
          selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
            background: Colors.orangeAccent.withOpacity(0.10),
          ),

          children: Utils.modelBuilder<String>(pickerValues, (index, value) {
            // final color = isSelected ? Colors.pink : Colors.black45;
            // final isSelected = this.selectedIndex == index;
            // final color = isSelected ? Colors.pink : Colors.black;
            return Center(
              child: Text(
                value,
                style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 16),
                // style: TextStyle(color: isSelected ? Colors.pink : Colors.black45, fontSize: 24),
              ),
            );
          }),
        ),
      );

  Widget buildHumidityNumberPicker(int pickerType) => SizedBox(
        height: 80,
        width: 50,
        child: CupertinoPicker(
          // backgroundColor: Colors.limeAccent,
          itemExtent: 48,
          diameterRatio: 1.5,
          looping: true,
          useMagnifier: true,
          magnification: 1.2,
          scrollController: FixedExtentScrollController(
              initialItem: initScrollIndex(pickerType)),
          // onSelectedItemChanged: (index) => setState(() => this.index = index),
          // onSelectedItemChanged: (index) => setState(() => this.selectedIndex = index),
          onSelectedItemChanged: (index) => setState(() {
            switch (pickerType) {
              case Constants.HUMID_LOWER:
                {
                  this.notificationDialog.notifyHumidLower =
                      double.parse(pickerValues[index].toString());
                  break;
                }
              case Constants.HUMID_HIGHER:
                {
                  this.notificationDialog.notifyHumidHigher =
                      double.parse(pickerValues[index].toString());
                  break;
                }
              default:
                {
                  this.notificationDialog.notifyHumidHigher =
                      double.parse(pickerValues[index].toString());
                  break;
                }
            }
          }),
          // onSelectedItemChanged: (int index) => setState(() {
          //   this.selectedIndex = index;
          //   print('onSelectedItemChanged this.index=${this.selectedIndex} | index=${index}');
          //   isSelected = this.selectedIndex == index;
          //   print('isSelected=${isSelected}');
          //
          // }),
          selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
            background: Colors.lightBlue.withOpacity(0.10),
          ),

          children: Utils.modelBuilder<String>(pickerValues, (index, value) {
            // final color = isSelected ? Colors.pink : Colors.black45;
            // final isSelected = this.selectedIndex == index;
            // final color = isSelected ? Colors.pink : Colors.black;
            return Center(
              child: Text(
                value,
                style: TextStyle(color: Colors.blue, fontSize: 16),
                // style: TextStyle(color: isSelected ? Colors.pink : Colors.black45, fontSize: 24),
              ),
            );
          }),
        ),
      );

  Widget buildTemperatureNotifyDialog() => SizedBox(
        height: 100,
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50,
                ),
                Text(
                  'Lower than',
                  style: TextStyle(color: Colors.black45),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Higher than',
                  style: TextStyle(color: Colors.black45),
                ),
                SizedBox(
                  width: 4,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Temperature',
                  style: TextStyle(color: Colors.black45),
                ),
                SizedBox(
                  width: 25,
                ),
                buildTemperatureNumberPicker(Constants.TEMP_LOWER),
                Text(
                  'or',
                  style: TextStyle(color: Colors.black45),
                ),
                buildTemperatureNumberPicker(Constants.TEMP_HIGHER),
              ],
            ),
          ],
        ),

        // child: CupertinoPicker(
        //   // backgroundColor: Colors.limeAccent,
        //   itemExtent: 48,
        //   diameterRatio: 1.5,
        //   looping: true,
        //   useMagnifier: true,
        //   magnification: 1.2,
        //   // onSelectedItemChanged: (index) => setState(() => this.index = index),
        //   onSelectedItemChanged: (index) => setState(() => this.selectedIndex = index),
        //   // onSelectedItemChanged: (int index) => setState(() {
        //   //   this.selectedIndex = index;
        //   //   print('onSelectedItemChanged this.index=${this.selectedIndex} | index=${index}');
        //   //   isSelected = this.selectedIndex == index;
        //   //   print('isSelected=${isSelected}');
        //   //
        //   // }),
        //   selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
        //     background: Colors.pink.withOpacity(0.10),
        //   ),
        //
        //   children: Utils.modelBuilder<String> (
        //       pickerValues,
        //           (index, value) {
        //         // final color = isSelected ? Colors.pink : Colors.black45;
        //         // final isSelected = this.selectedIndex == index;
        //         // final color = isSelected ? Colors.pink : Colors.black;
        //         return Center(
        //           child: Text(
        //             value,
        //             style: TextStyle(color: Colors.pink, fontSize: 16),
        //             // style: TextStyle(color: isSelected ? Colors.pink : Colors.black45, fontSize: 24),
        //           ),
        //         );
        //       }
        //   ),
        // ),
      );

  Widget buildHumidityNotifyDialog() => SizedBox(
        height: 100,
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50,
                ),
                Text(
                  'Lower than',
                  style: TextStyle(color: Colors.black45),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Higher than',
                  style: TextStyle(color: Colors.black45),
                ),
                SizedBox(
                  width: 4,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Humidity',
                  style: TextStyle(color: Colors.black45),
                ),
                SizedBox(
                  width: 10,
                ),
                buildHumidityNumberPicker(Constants.HUMID_LOWER),
                Text(
                  'or',
                  style: TextStyle(color: Colors.black45),
                ),
                buildHumidityNumberPicker(Constants.HUMID_HIGHER),
              ],
            ),
          ],
        ),

        // child: CupertinoPicker(
        //   // backgroundColor: Colors.limeAccent,
        //   itemExtent: 48,
        //   diameterRatio: 1.5,
        //   looping: true,
        //   useMagnifier: true,
        //   magnification: 1.2,
        //   // onSelectedItemChanged: (index) => setState(() => this.index = index),
        //   onSelectedItemChanged: (index) => setState(() => this.selectedIndex = index),
        //   // onSelectedItemChanged: (int index) => setState(() {
        //   //   this.selectedIndex = index;
        //   //   print('onSelectedItemChanged this.index=${this.selectedIndex} | index=${index}');
        //   //   isSelected = this.selectedIndex == index;
        //   //   print('isSelected=${isSelected}');
        //   //
        //   // }),
        //   selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
        //     background: Colors.pink.withOpacity(0.10),
        //   ),
        //
        //   children: Utils.modelBuilder<String> (
        //       pickerValues,
        //           (index, value) {
        //         // final color = isSelected ? Colors.pink : Colors.black45;
        //         // final isSelected = this.selectedIndex == index;
        //         // final color = isSelected ? Colors.pink : Colors.black;
        //         return Center(
        //           child: Text(
        //             value,
        //             style: TextStyle(color: Colors.pink, fontSize: 16),
        //             // style: TextStyle(color: isSelected ? Colors.pink : Colors.black45, fontSize: 24),
        //           ),
        //         );
        //       }
        //   ),
        // ),
      );

  int initScrollIndex(int pickerType) {
    int index = 0;
    switch (pickerType) {
      case Constants.HUMID_LOWER:
        {
          index = this.notification.notifyHumidLower.toInt();
          break;
        }
      case Constants.HUMID_HIGHER:
        {
          index = this.notification.notifyHumidHigher.toInt();
          break;
        }
      case Constants.TEMP_LOWER:
        {
          index = this.notification.notifyTempLower.toInt();
          break;
        }
      case Constants.TEMP_HIGHER:
        {
          index = this.notification.notifyTempHigher.toInt();
          break;
        }
      default:
        {
          index = 0;
          break;
        }
    }
    return index;
  }

  Widget drawNotificationDetail() {
    if (this.notification.isSendNotify) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'will send to',
              style: TextStyle(fontSize: 14, color: Colors.black45),
            ),
            Text(
              this.notification.notifyEmail,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'when',
              style: TextStyle(fontSize: 14, color: Colors.black45),
            ),
            // SizedBox(height: 8,),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Temperature is lower than ',
                  style: TextStyle(fontSize: 14, color: Colors.black45),
                ),
                Text(
                  '${this.notification.notifyTempLower}\u2103',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  ' or higher than ',
                  style: TextStyle(fontSize: 14, color: Colors.black45),
                ),
                Text(
                  '${this.notification.notifyTempHigher}\u2103',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Humidity is lower than ',
                  style: TextStyle(fontSize: 14, color: Colors.black45),
                ),
                Text(
                  '${this.notification.notifyHumidLower}',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  ' or higher than ',
                  style: TextStyle(fontSize: 14, color: Colors.black45),
                ),
                Text(
                  '${this.notification.notifyHumidHigher}',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),

            // buildCustomPicker(),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'none',
              style: TextStyle(fontSize: 14, color: Colors.black45),
            ),
            // buildCustomPicker(),
          ],
        ),
      );
    }
  }

  Widget drawLineChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 2,
            right: 2,
          ),
          // child: LineChartSample10(),
          child: SizedBox(
            width: displayWidth(context) * 0.6,
            height: 150,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(
                    show: true,
                    border:
                        Border.all(color: const Color(0xff37434d), width: 1)),
                minY: 0,
                maxY: 100,
                minX: tempPoints.first.x,
                maxX: tempPoints.last.x,
                // lineTouchData: LineTouchData(enabled: true),
                lineTouchData: lineTouchData1,
                clipData: FlClipData.all(),
                // gridData: FlGridData(
                //   show: true,
                //   drawVerticalLine: false,
                // ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  drawHorizontalLine: true,
                  horizontalInterval: 10,
                  verticalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xffb9c4c9),
                      strokeWidth: 0.5,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: const Color(0xffb9c4c9),
                      strokeWidth: 0.5,
                    );
                  },
                ),
                lineBarsData: [
                  tempLine(tempPoints),
                  humidLine(humidPoints),
                ],
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                      // reservedSize: 38,
                    ),
                  ),
                  bottomTitles: AxisTitles(

                    sideTitles: SideTitles(
                      showTitles: false,

                      // reservedSize: 38,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Indicator(
              color: Colors.orangeAccent,
              text: 'Temperature',
              isSquare: true,
            ),
            SizedBox(
              height: 4,
            ),
            Indicator(
              color: Colors.blueAccent,
              text: 'Humidity',
              isSquare: true,
            ),
            SizedBox(
              height: 18,
            ),
          ],
        ),
      ],
    );
  }
}

class TempAndHumidCircularWidget extends StatelessWidget {
  const TempAndHumidCircularWidget({
    Key? key,
    required this.weatherHistory,
    required this.headlineStyle,
    required this.unitStyle,
  }) : super(key: key);

  final WeatherHistory weatherHistory;
  final TextStyle? headlineStyle;
  final TextStyle? unitStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: new BoxDecoration(
          color: Colors.lightGreen.shade800,
          border: Border.all(color: Colors.green.shade400, width: 8.0),
          borderRadius: new BorderRadius.all(Radius.circular(150.0)),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    child: Text(
                      '${globals.formatNumber(weatherHistory.weatherData.temperature) ?? ''}',
                      // '${globals.formatNumber(weatherHistory?.weatherData?.temperature is double ? weatherHistory?.weatherData?.temperature : 0)}',
                      style: headlineStyle,
                      // style: TextStyle(
                      //   color: Colors.white,
                      //   fontFamily: 'Kanit',
                      //   fontWeight: FontWeight.w300,
                      //   fontSize: 36.0,
                      // ),
                    ),
                  ),
                  Container(
                    child: Text(
                      'Temperature (\u2103)',
                      style: unitStyle,
                    ),
                  ),
                ],
              ),
              VerticalDivider(
                color: Colors.grey.withOpacity(0.2),
                thickness: 2,
                // width: 10,
                indent: 10,
                endIndent: 10,
              ),
              Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    child: Text(
                      '${globals.formatNumber(weatherHistory.weatherData.humidity) ?? ''}',
                      style: headlineStyle,
                      // style: TextStyle(
                      //   color: Colors.white,
                      //   fontFamily: 'Kanit',
                      //   fontWeight: FontWeight.w300,
                      //   fontSize: 36.0,
                      // ),
                    ),
                  ),
                  Container(
                    child: Text(
                      'Humidity (%)',
                      style: unitStyle,
                      // style: TextStyle(
                      //   color: Colors.white,
                      //   fontFamily: 'Kanit',
                      //   fontWeight: FontWeight.w300,
                      //   fontSize: 12.0,
                      // ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TankDimensionConfig extends StatefulWidget {
  final Device device;
  final String selectedTankType;
  final Tank tankDialog;



  const TankDimensionConfig({Key? key,
    required this.device,
    required this.selectedTankType,
    required this.tankDialog,

  }) : super(key: key);

  @override
  State<TankDimensionConfig> createState() => _TankDimensionConfigState();
}

class _TankDimensionConfigState extends State<TankDimensionConfig> {
  String _SelectedTankType = Constants.TANK_TYPE_VERTICAL_CYLINDER;
  bool _VisibilityHWL = true;
  bool _VisibilityLD = false;
  int _InitScrollIndex = 0;
  var f = NumberFormat("###.##", "en_US");

  @override
  void initState() {
    int index = 0;
    print('widget.selectedTankType=${widget.selectedTankType}');
    print('widget.device.wTankType=${widget.device.wTankType}');
    Constants.gTankTypesMap.keys.forEach((String key) {
      if(key == widget.device.wTankType) {
        _InitScrollIndex = index;
      }
      index++;
    });
    _SelectedTankType = widget.device.wTankType;
    print('_InitScrollIndex=${_InitScrollIndex}');
    if(_InitScrollIndex == 0) {
      _SelectedTankType = Constants.gTankTypesMap!.keys.elementAt(0);
    }
    print('_SelectedTankType=${_SelectedTankType}');
  }

  static Key getDimensionKey(String dimensionType) {
    switch(dimensionType) {
      case Constants.DIMENSION_TYPE_LENGTH: {
        return _ShowDevicePageState._lengthFormKey;
      }
      case Constants.DIMENSION_TYPE_DIAMETER: {
        return _ShowDevicePageState._diameterFormKey;
      }
      case Constants.DIMENSION_TYPE_HEIGHT: {
        return _ShowDevicePageState._heightFormKey;
      }
      case Constants.DIMENSION_TYPE_CAPACITY: {
        return _ShowDevicePageState._capacityFormKey;
      }
      case Constants.DIMENSION_TYPE_WIDTH: {
        return _ShowDevicePageState._widthFormKey;
      }
      case Constants.DIMENSION_TYPE_SIDE_LENGTH: {
        return _ShowDevicePageState._sideLengthFormKey;
      }
      default: {
        return _ShowDevicePageState._lengthFormKey;
      }
    }
  }

  String getDimensionValue(String dimensionType) {
    String result = '';
    switch(dimensionType) {
      case Constants.DIMENSION_TYPE_CAPACITY: {
        result = !_ShowDevicePageState.tank.wCapacity!.isNaN ? f.format(_ShowDevicePageState.tank.wCapacity!).toString() : '';
        break;
      }
      case Constants.DIMENSION_TYPE_LENGTH: {
        result = !_ShowDevicePageState.tank.wLength!.isNaN ? f.format(_ShowDevicePageState.tank.wLength!).toString() : '';
        break;
      }
      case Constants.DIMENSION_TYPE_DIAMETER: {
        result = !_ShowDevicePageState.tank.wDiameter!.isNaN ? f.format(_ShowDevicePageState.tank.wDiameter!).toString() : '';
        break;
      }
      case Constants.DIMENSION_TYPE_HEIGHT: {
        result = !_ShowDevicePageState.tank.wHeight!.isNaN ? f.format(_ShowDevicePageState.tank.wHeight!).toString() : '';
        break;
      }
      case Constants.DIMENSION_TYPE_WIDTH: {
        result = !_ShowDevicePageState.tank.wWidth!.isNaN ? f.format(_ShowDevicePageState.tank.wWidth!).toString() : '';
        break;
      }
      case Constants.DIMENSION_TYPE_SIDE_LENGTH: {
        result = !_ShowDevicePageState.tank.wSideLength!.isNaN ? f.format(_ShowDevicePageState.tank.wSideLength!).toString() : '';
        break;
      }
      default: {
        result = '';
      }
    }
    print('getDimensionValue[${dimensionType}] _ShowDevicePageState.tank.wLength![${_ShowDevicePageState.tank.wLength!}] result=${result} ');
    print('getDimensionValue[${dimensionType}] widget.tankDialog.wHeight![${widget.tankDialog.wHeight!}] result=${result} ');
    return result;
  }

  void setDimensionValue(String dimensionType, String value) {
    if(value != '') {
      switch (dimensionType) {
        case Constants.DIMENSION_TYPE_CAPACITY:
          {
            widget.device.wCapacity = double.parse(value);
            widget.tankDialog.wCapacity = double.parse(value);

            print('>> widget.device.wCapacity=${widget.device.wCapacity}');
            print(
                '>> widget.tankDialog.wCapacity=${widget
                    .tankDialog.wCapacity}');
            break;
          }
        case Constants.DIMENSION_TYPE_LENGTH:
          {
            widget.device.wLength = double.parse(value);
            widget.tankDialog.wLength = double.parse(value);

            print('>> widget.device.wLength=${widget.device.wLength}');
            print(
                '>> widget.tankDialog.wLength=${widget
                    .tankDialog.wLength}');
            break;
          }
        case Constants.DIMENSION_TYPE_DIAMETER:
          {
            widget.device.wDiameter = double.parse(value);
            widget.tankDialog.wDiameter = double.parse(value);
            print('>> widget.device.wDiameter=${widget.device.wDiameter}');
            print('>> widget.tank.wDiameter=${widget
                .tankDialog.wDiameter}');
            break;
          }
        case Constants.DIMENSION_TYPE_HEIGHT:
          {
            widget.device.wHeight = double.parse(value);
            widget.tankDialog.wHeight = double.parse(value);
            print('>> widget.device.wHeight=${widget.device.wHeight}');
            print('>> widget.tank.wHeight=${widget
                .tankDialog.wHeight}');
            break;
          }
        case Constants.DIMENSION_TYPE_WIDTH:
          {
            widget.device.wWidth = double.parse(value);
            widget.tankDialog.wWidth = double.parse(value);
            print('>> widget.device.wWidth=${widget.device.wWidth}');
            print('>> widget.tank.wWidth=${widget
                .tankDialog.wWidth}');
            break;
          }
        case Constants.DIMENSION_TYPE_SIDE_LENGTH:
          {
            widget.device.wSideLength = double.parse(value);
            widget.tankDialog.wSideLength = double.parse(value);
            print('>> widget.device.wSideLength=${widget.device.wSideLength}');
            print(
                '>> widget.tank.wSideLength=${widget
                    .tankDialog.wSideLength}');
            break;
          }
        default:
          {
            break;
          }
      }
    }
  }

  Widget buildTankTypeDimensionForm(String tankType) {
    List<Widget> list = <Widget>[];
    if (tankType == '') {
      tankType = Constants.TANK_TYPE_VERTICAL_CYLINDER;
    }

    Constants.gTankTypesMap[tankType]!.forEach((dimensionTypeName, symbol) {
      list.add(SizedBox(
        height: displayHeight(context) * 0.08, // MediaQuery.of(context).size.height / 2,

        child: Container(child: Row(

          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Text('$dimensionTypeName: ', style: TextStyle(color: Colors.black87),),
            // Text('_ ', style: TextStyle(color: Colors.black87),),
            Container(
              width: 100,
              height: 40,
              child: Form(
                key: getDimensionKey(dimensionTypeName),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.normal, ),
                  initialValue: getDimensionValue(dimensionTypeName),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      // return 'Please enter a ${dimensionTypeName} tank dimension number.';
                      return 'Re-edit here';
                    } else {
                      // if (!isNumeric(value!)) {
                      //   return 'Invalid ${dimensionTypeName} tank dimension number';
                      // }
                      // setState(() {
                      //   // setDimensionValue(dimensionTypeName, value);
                      //   print('*** ${dimensionTypeName} value=${value}');
                      // });

                      return null;
                    }
                  },
                  // controller: TextEditingController(text: this.notificationDialog.notifyEmail),
                  autofocus: false,
                  // decoration: InputDecoration(
                  //   label: Text(
                  //     'Email:',
                  //     style: TextStyle(fontSize: 16, color: Colors.black45),
                  //   ),
                  //   // labelText: Text('Email:'),
                  //   hintText: 'Enter your email address',
                  // ),
                  // controller: name_controller,
                  onChanged: (value) {
                      setState(() {
                        setDimensionValue(dimensionTypeName, value);
                        print('+++ ${dimensionTypeName} value=${value}');
                      });
                  },
                  // onSubmitted: (_) => submitNotificationSettings(),
                ),
              ),
            ),
            Text('${symbol}', style: TextStyle(color: Colors.black87),),
          ],
        )),
      ));
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: list,
    );
  }

  List<Widget> buildTankTypesConfiguration() {
    List<Widget> results = [];
    Constants.gTankTypesMap!.forEach((name, symbol) {
      results.add(Container(
          height: 300,//displayHeight(context) * 0.4, // MediaQuery.of(context).size.height / 2,
          width: displayWidth(context) * 0.6,
          color: Colors.deepOrangeAccent,
          child: Card(
              color: Colors.black12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    // width: displayWidth(context) * 0.2,
                    height: displayHeight(context) * 0.15,
                    child: Image(
                      image: AssetImage(
                          Constants.gTankImagesMap[name]!),
                      // 'images/tanks/base_vertical_cylinder.jpg'),
                    ),
                  ),
                  // Text('$name'),
                ],
              ))

      )
      );
    });
    return results;
  }

  void changeVisibility() {
    setState(() {
      _VisibilityHWL = !_VisibilityHWL;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(child: Text('${_SelectedTankType}', style: TextStyle(color: Colors.black87, fontSize: 18)),),
          SizedBox(
            height: displayHeight(context) * 0.4, // MediaQuery.of(context).size.height / 2,
            width: displayWidth(context) * 0.6,
            child: ListWheelScrollView(
              controller: FixedExtentScrollController(initialItem: _InitScrollIndex),
              itemExtent: displayWidth(context) * 0.35,
              // itemExtent: 100,
              children: buildTankTypesConfiguration(),
              // children: items,
              // value between 0 --> 0.01
              perspective: 0.009,
              diameterRatio: 1.5,
              // default 2.0
              // useMagnifier: true,
              magnification: 1.1,
              physics: FixedExtentScrollPhysics(),

              onSelectedItemChanged: (index) {
                print('index====$index');
                setState(() {
                  _SelectedTankType =
                      Constants.gTankTypesMap!.keys.elementAt(index);
                  _ShowDevicePageState.mSelectedTankType = _SelectedTankType;
                  switch (_SelectedTankType) {
                    case Constants.TANK_TYPE_SIMPLE: {
                      break;
                    }
                    case Constants.TANK_TYPE_RECTANGLE:
                    case Constants.TANK_TYPE_HORIZONTAL_OVAL:
                    case Constants.TANK_TYPE_VERTICAL_OVAL:
                    case Constants.TANK_TYPE_HORIZONTAL_ELLIPSE:
                      {
                        _VisibilityHWL = true;
                        _VisibilityLD = false;
                        break;
                      }
                    case Constants.TANK_TYPE_VERTICAL_CYLINDER:
                    case Constants.TANK_TYPE_HORIZONTAL_CYLINDER:
                    case Constants.TANK_TYPE_HORIZONTAL_CAPSULE:
                    case Constants.TANK_TYPE_VERTICAL_CAPSULE:
                    case Constants
                        .TANK_TYPE_HORIZONTAL_2_1_ELLIPTICAL:
                    case Constants.TANK_TYPE_HORIZONTAL_DISH_ENDS:
                      {
                        _VisibilityHWL = false;
                        _VisibilityLD = true;
                        break;
                      }
                  }

                  // toast('index====$index | mTankType=$mSelectedTankType | mVisibilityHWL=$mVisibilityHWL');
                });
              },
            ),
          ),
          Container(child: buildTankTypeDimensionForm(_SelectedTankType)),
        ],
      ),
    );
  }
}
