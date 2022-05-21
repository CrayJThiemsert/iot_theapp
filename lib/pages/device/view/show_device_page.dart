import 'package:after_layout/after_layout.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iot_theapp/pages/device/database/device_database.dart';
import 'package:iot_theapp/pages/device/model/device.dart';
import 'package:iot_theapp/pages/device/model/notification.dart' as Notify;
import 'package:iot_theapp/pages/device/model/weather_history.dart';
import 'package:iot_theapp/pages/device/view/line_chart_live.dart';
import 'package:iot_theapp/pages/device/view/utils.dart';
import 'package:iot_theapp/pages/user/model/user.dart';
import 'package:iot_theapp/utils/constants.dart';

import 'package:http/http.dart' as http;
import 'package:iot_theapp/globals.dart' as globals;
import 'package:validators/validators.dart';

import '../../../line_chart_sample10.dart';
import 'indicator.dart';

class ShowDevicePage extends StatefulWidget {
  final String deviceUid;
  final Device device;

  final weekDays = const ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  final List<double> yValues = const [1.3, 1, 1.8, 1.5, 2.2, 1.8, 3];

  const ShowDevicePage({
    Key? key,
    required this.deviceUid,
    required this.device}) : super(key: key);

  @override
  _ShowDevicePageState createState() => _ShowDevicePageState(deviceUid, device);
}

class _ShowDevicePageState extends State<ShowDevicePage> with AfterLayoutMixin<ShowDevicePage> {
  String deviceUid = '';
  Device device = Device();
  Notify.Notification notification = Notify.Notification();
  Notify.Notification notificationDialog = Notify.Notification();
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
  int selectedIndex = 0;

  bool _checked = false;
  // Color color = Colors.black45;
  // bool isSelected = false;

  _ShowDevicePageState(this.deviceUid, this.device);


  @override
  void initState() {
    touchedValue = -1;

    // for(int i=0; i < 100;i++) {
    //   pickerValues[i] = i.toString();
    // }
    // print('pickerValues.length=${pickerValues.length}');

    super.initState();
    notification = Notify.Notification();

    // --------------------
    tempPoints.add(FlSpot(xValue, 0));
    humidPoints.add(FlSpot(xValue, 0));
    dateTimeValues.add('_');
    print('init state');
    print('tempPoints[tempPoints.length-1].x=${tempPoints[tempPoints.length-1].x}');
    print('tempPoints[tempPoints.length-1].y=${tempPoints[tempPoints.length-1].y}');
    print('dateTimeValues[dateTimeValues.length-1]=${dateTimeValues[dateTimeValues.length-1]}');
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
          if(barSpot.barIndex == 1) {
            dateTimeString = '${dateTimeValues[flSpot.x.toInt()].toString()}\n';
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
    // var deviceRef = FirebaseDatabase.instance.reference().child('users/${user.uid}/devices/${device.uid}/${device.uid}_history/2021-03-31 01:32:01');
    final TextStyle? unitStyle = Theme.of(context).textTheme.headline2;
    final TextStyle? headlineStyle = Theme.of(context).textTheme.headline1;

    return StreamBuilder(
        // stream: deviceDatabase.getLatestHistory().onValue,
        stream: deviceHistoryRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapHistory) {
          if (snapHistory.hasData && !snapHistory.hasError) {
            print('=>${snapHistory.data!.snapshot.value.toString()}');
            var weatherHistory =
                WeatherHistory.fromJson(snapHistory.data!.snapshot.value as Map);
            // var weatherHistory = WeatherHistory.fromSnapshot(snap.data.snapshot);

            // Prepare value to draw live line chart
            while (tempPoints.length > limitCount) {
              tempPoints.removeAt(0);
              humidPoints.removeAt(0);
            }
            // used to be setState
            print('xValue=${xValue}, weatherHistory.temperature=${weatherHistory.weatherData.temperature}|${globals.formatNumber(weatherHistory.weatherData.temperature) ?? ''}');
            print('xValue=${xValue}, weatherHistory.humidity=${weatherHistory.weatherData.humidity}');
              tempPoints.add(FlSpot(xValue, weatherHistory.weatherData.temperature));
              humidPoints.add(FlSpot(xValue, weatherHistory.weatherData.humidity));
            dateTimeValues.add(weatherHistory.weatherData.uid);

            print('tempPoints[tempPoints.length-1].x=${tempPoints[tempPoints.length-1].x}');
            print('tempPoints[tempPoints.length-1].y=${tempPoints[tempPoints.length-1].y}');
            print('tempPoints.length=${tempPoints.length}');
            xValue += step;

            return StreamBuilder(
              stream: deviceNotificationRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapNotification) {
                if (snapNotification.hasData && !snapNotification.hasError) {

                  print('snapNotification.hasData=${snapNotification.hasData}');
                  print('=>${snapNotification.data!.snapshot.value.toString()}');
                  if(snapNotification.data!.snapshot.value != null) {
                    print('snapNotification.data!.snapshot.value is not null!!');
                    var notificationStream =
                    Notify.Notification.fromJson(snapNotification.data!.snapshot.value as Map);

                    // Stream Notification Data from cloud
                    this.notification.notifyEmail = notificationStream.notifyEmail;
                    this.notification.notifyTempHigher = notificationStream.notifyTempHigher;
                    this.notification.notifyTempLower = notificationStream.notifyTempLower;
                    this.notification.notifyHumidHigher = notificationStream.notifyHumidHigher;
                    this.notification.notifyHumidLower = notificationStream.notifyHumidLower;
                    this.notification.isSendNotify = notificationStream.isSendNotify;
                  } else {
                    print('snapNotification.data!.snapshot.value is null!!');
                  }

                  print('this.notification.isSendNotify=${this.notification.isSendNotify}');
                  print('this.notification.notifyEmail=${this.notification.notifyEmail}');
                  print('this.notification.notifyTempHigher=${this.notification.notifyTempHigher}');
                  print('this.notification.notifyTempLower=${this.notification.notifyTempLower}');
                  print('this.notification.notifyHumidHigher=${this.notification.notifyHumidHigher}');
                  print('this.notification.notifyHumidLower=${this.notification.notifyHumidLower}');


                }
                return Scaffold(
                  appBar: AppBar(
                    title: Text('${device.name ?? device.uid} Detail'),
                  ),
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 12,),
                        Center(
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
                                      SizedBox(height: 50,),
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
                                      SizedBox(height: 50,),
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
                        ),
                        SizedBox(height: 12,),
                        Center(
                          child: Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Device ', style: TextStyle( fontSize: 14, color: Colors.black45),),
                                Text('${device.name ?? device.uid}', style: TextStyle( fontSize: 14, color: Colors.black87),),
                                Text(' Detail', style: TextStyle( fontSize: 14, color: Colors.black45),),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('latest when ', style: TextStyle( fontSize: 14, color: Colors.black45),),
                                Text('${weatherHistory?.weatherData?.uid ?? 'no data'}', style: TextStyle( fontSize: 14, color: Colors.black87),),
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
                                Text('battery voltage ', style: TextStyle( fontSize: 14, color: Colors.black45),),
                                Text('${weatherHistory?.weatherData?.readVoltage ?? 'no data'}', style: TextStyle( fontSize: 14, color: Colors.black87),),
                                Text(' volts', style: TextStyle( fontSize: 14, color: Colors.black45),),
                              ],
                            ),
                          ),
                        ),
                        buildReadingIntervalCard(context),
                        SizedBox(height: 8,),
                        // draw line chart

                        drawLineChart(),

                        // Notification setting
                        SizedBox(height: 8,),
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
                            // final name = await openNotificationInputDialog();
                            // if(name == null || name.isEmpty) return;
                            //
                            // setState(() {
                            //   this.name = name;
                            // });

                            // // Prepare notification values before edit them on dialog.
                            // this.notificationDialog = this.notification;

                            final deviceReturn = await openNotificationInputDialog();
                            if(deviceReturn == null) return;

                            setState(() {
                              this.notification.notifyTempLower = deviceReturn.notifyTempLower;
                              this.notification.notifyTempHigher = deviceReturn.notifyTempHigher;
                              this.notification.notifyHumidLower = deviceReturn.notifyHumidLower;
                              this.notification.notifyHumidHigher = deviceReturn.notifyHumidHigher;
                              this.notification.notifyEmail = deviceReturn.notifyEmail;
                              // this.notification.isSendNotify = deviceReturn.isSendNotify;
                            });
                          },

                        ),
                        SizedBox(height: 8,),
                        // Notification display
                        drawNotificationDetail(),

                        SizedBox(height: 16,),
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
              }
            );
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
              )
            );
          }
        });
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
                                tooltip: 'Continue read sensor value every short time period',
                                onPressed: () {
                                  setState(() {
                                    burstePressed = !burstePressed;
                                    requestPressed = false;
                                    pollingPressed = false;
                                    offlinePressed = false;
                                  });
                                },
                              ),
                              Text('Burst', style: burstePressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
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
                              Text('Request', style: requestPressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
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
                                tooltip: 'Read sensor value every long time period to safe battery life time',
                                onPressed: () {
                                  setState(() {
                                    burstePressed = false;
                                    requestPressed = false;
                                    pollingPressed = !pollingPressed;
                                    offlinePressed = false;
                                  });
                                },
                              ),
                              Text('Polling', style: pollingPressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
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
                                tooltip: 'Save read sensor value in "the Node" local memory',
                                onPressed: () {
                                  setState(() {
                                    burstePressed = false;
                                    requestPressed = false;
                                    pollingPressed = false;
                                    offlinePressed = !offlinePressed;
                                  });
                                },
                              ),
                              Text('Offline', style: offlinePressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
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
                    Text('10', style: sec10Pressed ? activeStyle : inactiveStyle,),
                    Text('sec', style: sec10Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
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
                    Text('30', style: sec30Pressed ? activeStyle : inactiveStyle,),
                    Text('sec', style: sec30Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
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
                    Text('1', style: min1Pressed ? activeStyle : inactiveStyle,),
                    Text('min', style: min1Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
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
                    Text('5', style: min5Pressed ? activeStyle : inactiveStyle,),
                    Text('min', style: min5Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
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
                    Text('30', style: min30Pressed ? activeStyle : inactiveStyle,),
                    Text('min', style: min30Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
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
                    Text('1', style: hour1Pressed ? activeStyle : inactiveStyle,),
                    Text('hour', style: hour1Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
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
                    Text('2', style: hour2Pressed ? activeStyle : inactiveStyle,),
                    Text('hour', style: hour2Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
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
                    Text('3', style: hour3Pressed ? activeStyle : inactiveStyle,),
                    Text('hour', style: hour3Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
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
                    Text('4', style: hour4Pressed ? activeStyle : inactiveStyle,),
                    Text('hour', style: hour4Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
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
    print('update reading interval in cloud database - users/${user.uid}/devices/${device.uid}');
    var deviceRef = FirebaseDatabase.instance
        .ref()
        .child('users/${user.uid}/devices/${device.uid}')
        .update({
      // 'name':  device.name,
      'readingInterval': selectedInterval,
    }).onError((error, stackTrace) => print('updateNotificationSettings error=${error.toString()}'))
        .whenComplete(() {
      print('updated notification settings success.');
      showDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Text("Update Successfully"),
            content: Text("Update reading interval settings is successfully."),
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
          barrierDismissible: false
      );

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

  /**
   * "the Node" to save notification values
   */
  Future<void> updateNotificationSettings() async {
    // update notification settings in cloud database
    print('update notification settings in cloud database - users/${user.uid}/devices/${device.uid}/notification');
    var deviceRef = FirebaseDatabase.instance
        .ref()
        .child('users/${user.uid}/devices/${device.uid}/notification')
        .update({
      // 'name':  device.name,
      'notifyHumidLower': (this.notificationDialog.notifyHumidLower == 0) ? this.notification.notifyHumidLower : this.notificationDialog.notifyHumidLower,
      'notifyHumidHigher': (this.notificationDialog.notifyHumidHigher == 0) ? this.notification.notifyHumidHigher : this.notificationDialog.notifyHumidHigher,
      'notifyTempLower': (this.notificationDialog.notifyTempLower == 0) ? this.notification.notifyTempLower : this.notificationDialog.notifyTempLower,
      'notifyTempHigher': (this.notificationDialog.notifyTempHigher == 0) ? this.notification.notifyTempHigher : this.notificationDialog.notifyTempHigher,
      'notifyEmail': this.notificationDialog.notifyEmail,
      'isSendNotify': this.notification.isSendNotify,
    }).onError((error, stackTrace) => print('updateNotificationSettings error=${error.toString()}'))
    .whenComplete(() {
      print('updated notification settings success.');
      showDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Text("Update Successfully"),
            content: Text("Update notification settings is successfully."),
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

    if(onceHistoriesSnapshot.exists) {
      histories.clear();
      tempPoints.clear();
      humidPoints.clear();
      dateTimeValues.clear();

      print(onceHistoriesSnapshot.value);
      Map<dynamic, dynamic>? values = onceHistoriesSnapshot.value as Map?;

      values!.forEach((key, weatherValues) {
        print('key=${key}');
        print('temperature=[${weatherValues['temperature']}]');

        tempPoints.add(FlSpot(xValue, globals.parseDouble(weatherValues['temperature'] ?? 0)));
        humidPoints.add(FlSpot(xValue, globals.parseDouble(weatherValues['humidity'] ?? 0)));
        dateTimeValues.add(weatherValues['uid'] ?? '');

        xValue += step;

        histories.add(WeatherData(
            uid: weatherValues['uid'] ?? '',
            deviceId: weatherValues['deviceId'] ?? '',
            humidity: globals.parseDouble(weatherValues['humidity'] ?? 0),
            temperature: globals.parseDouble(weatherValues['temperature'] ?? 0),
            readVoltage: globals.parseDouble(weatherValues['readVoltage'] ?? 0)

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
    switch(device.readingInterval) {
      case Constants.INTERVAL_SECOND_10: {
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

      case Constants.INTERVAL_SECOND_30: {
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

      case Constants.INTERVAL_MINUTE_1: {
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

      case Constants.INTERVAL_MINUTE_5: {
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

      case Constants.INTERVAL_MINUTE_30: {
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

      case Constants.INTERVAL_HOUR_1: {
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

      case Constants.INTERVAL_HOUR_2: {
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

      case Constants.INTERVAL_HOUR_3: {
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

      case Constants.INTERVAL_HOUR_4: {
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

      default: {
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

  Future<Notify.Notification?> openNotificationInputDialog() => showDialog<Notify.Notification>(

      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.only(top: 2.0, left: 4.0, right: 4.0, ),
        title: Container(
          alignment: Alignment.topCenter,
            child: Text('Notification')),
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
                    decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
                    child: CheckboxListTile(

                      title: Text('Send notification email', style: TextStyle(fontSize: 16, color: Colors.black87),),
                      subtitle: Text('Enable send the notification email when it meet condition.', style: TextStyle(fontSize: 12, color: Colors.black38),),
                      secondary: Icon(Icons.mail_outline),
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: this.notification.isSendNotify,
                      selected: this.notification.isSendNotify,
                      // value: _checked,
                      onChanged: (bool? value) {
                        setState(() {
                          this.notification.isSendNotify = value!;
                          // this.notificationDialog.isSendNotify = value!;
                          // _checked = value!;
                          print('check value=${value}');
                        });
                      },
                      activeColor: Colors.lightGreen,
                      checkColor: Colors.yellow,

                    ),
                  );
                }
              ),

              // Text('will send to', style: TextStyle( fontSize: 16, color: Colors.black45),),
              Form(
                key: _emailFormKey,
                child: TextFormField(
                  initialValue: this.notification.notifyEmail,
                  keyboardType: TextInputType.emailAddress,
                  // validator: (val) => !isEmail(val!) ? 'Invalid Email' : null,
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return 'Please enter some text';
                    } else {
                      if(!isEmail(value!)) {
                        return 'Invalid Email';
                      }
                      setState(() {
                        this.notificationDialog.notifyEmail = value;
                      });

                      return null;
                    }
                  },
                  // controller: TextEditingController(text: this.notificationDialog.notifyEmail),
                  autofocus: false,
                  decoration: InputDecoration(
                    label: Text('Email:', style: TextStyle( fontSize: 16, color: Colors.black45),),
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
              SizedBox(height: 16,),
              Text('when', style: TextStyle( fontSize: 16, color: Colors.black45),),
              SizedBox(height: 16,),
              buildTemperatureNotifyDialog(),
              SizedBox(height: 8,),
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
            child: Text('CLOSE')
          ),
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
                      content: Text("Please enter the correct email format.\ And submit again."),
                      actions: [
                        CupertinoDialogAction(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    barrierDismissible: false
                );
              }

            },
            child: Text('SUBMIT')
          ),
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
      scrollController: FixedExtentScrollController(initialItem: initScrollIndex(pickerType)) ,
      // onSelectedItemChanged: (index) => setState(() => this.index = index),
      // onSelectedItemChanged: (index) => setState(() => this.selectedIndex = index),
      onSelectedItemChanged: (index) => setState(() {
        switch(pickerType) {
          case Constants.TEMP_LOWER: {
            this.notificationDialog.notifyTempLower = double.parse(pickerValues[index].toString());
            break;
          }
          case Constants.TEMP_HIGHER: {
            this.notificationDialog.notifyTempHigher = double.parse(pickerValues[index].toString());
            break;
          }
          default: {
            this.notificationDialog.notifyTempLower = double.parse(pickerValues[index].toString());
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
        background: Colors.orangeAccent.withOpacity(0.10),
      ),

      children: Utils.modelBuilder<String> (
        pickerValues,
        (index, value) {
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
        }
      ),
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
      scrollController: FixedExtentScrollController(initialItem: initScrollIndex(pickerType)) ,
      // onSelectedItemChanged: (index) => setState(() => this.index = index),
      // onSelectedItemChanged: (index) => setState(() => this.selectedIndex = index),
      onSelectedItemChanged: (index) => setState(() {
        switch(pickerType) {
          case Constants.HUMID_LOWER: {
            this.notificationDialog.notifyHumidLower = double.parse(pickerValues[index].toString());
            break;
          }
          case Constants.HUMID_HIGHER: {
            this.notificationDialog.notifyHumidHigher = double.parse(pickerValues[index].toString());
            break;
          }
          default: {
            this.notificationDialog.notifyHumidHigher = double.parse(pickerValues[index].toString());
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

      children: Utils.modelBuilder<String> (
          pickerValues,
              (index, value) {
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
          }
      ),
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
            SizedBox(width: 50,),
            Text('Lower than', style: TextStyle(color: Colors.black45),),
            SizedBox(width: 20,),
            Text('Higher than', style: TextStyle(color: Colors.black45),),
            SizedBox(width: 4,),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Temperature', style: TextStyle(color: Colors.black45),),
            SizedBox(width: 25,),
            buildTemperatureNumberPicker(Constants.TEMP_LOWER),
            Text('or', style: TextStyle(color: Colors.black45),),
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
            SizedBox(width: 50,),
            Text('Lower than', style: TextStyle(color: Colors.black45),),
            SizedBox(width: 20,),
            Text('Higher than', style: TextStyle(color: Colors.black45),),
            SizedBox(width: 4,),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Humidity', style: TextStyle(color: Colors.black45),),
            SizedBox(width: 10,),
            buildHumidityNumberPicker(Constants.HUMID_LOWER),
            Text('or', style: TextStyle(color: Colors.black45),),
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
    switch(pickerType) {
      case Constants.HUMID_LOWER: {
        index = this.notification.notifyHumidLower.toInt();
        break;
      }
      case Constants.HUMID_HIGHER: {
        index = this.notification.notifyHumidHigher.toInt();
        break;
      }
      case Constants.TEMP_LOWER: {
        index = this.notification.notifyTempLower.toInt();
        break;
      }
      case Constants.TEMP_HIGHER: {
        index = this.notification.notifyTempHigher.toInt();
        break;
      }
      default: {
        index = 0;
        break;
      }
    }
    return index;
  }

  Widget drawNotificationDetail() {
    if(this.notification.isSendNotify) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('will send to', style: TextStyle( fontSize: 14, color: Colors.black45),),
            Text(
              this.notification.notifyEmail,
              style: TextStyle( fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 16,),
            Text('when', style: TextStyle( fontSize: 14, color: Colors.black45),),
            // SizedBox(height: 8,),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Temperature is lower than ', style: TextStyle( fontSize: 14, color: Colors.black45),),
                Text('${this.notification.notifyTempLower}\u2103', style: TextStyle( fontSize: 14, color: Colors.black87),),
                Text(' or higher than ', style: TextStyle( fontSize: 14, color: Colors.black45),),
                Text('${this.notification.notifyTempHigher}\u2103', style: TextStyle( fontSize: 14, color: Colors.black87),),
              ],
            ),
            SizedBox(height: 8,),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Humidity is lower than ', style: TextStyle( fontSize: 14, color: Colors.black45),),
                Text('${this.notification.notifyHumidLower}', style: TextStyle( fontSize: 14, color: Colors.black87),),
                Text(' or higher than ', style: TextStyle( fontSize: 14, color: Colors.black45),),
                Text('${this.notification.notifyHumidHigher}', style: TextStyle( fontSize: 14, color: Colors.black87),),
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
            Text('none', style: TextStyle( fontSize: 14, color: Colors.black45),),
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
            left: 28,
            right: 28,
          ),
          // child: LineChartSample10(),
          child: SizedBox(
            width: 150,
            height: 150,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1)),
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
                  drawVerticalLine: true,
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
