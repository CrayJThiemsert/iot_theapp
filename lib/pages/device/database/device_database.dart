import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebaseauth;
import 'package:firebase_database/firebase_database.dart';
import 'package:iot_theapp/pages/device/model/device.dart';
import 'package:iot_theapp/pages/device/model/weather_history.dart';
import 'package:iot_theapp/pages/user/model/user.dart';


class DeviceDatabase {
  late DatabaseReference _deviceRef;
  late DatabaseReference _historyRef;
  late StreamSubscription<Event> _historySubscription;
  late StreamSubscription<Event> _messagesSubscription;
  // Demonstrates configuring the database directly
  final FirebaseDatabase database = FirebaseDatabase();
  late WeatherHistory _weatherHistoryValue;
  DatabaseError? error;

  late User user = User();
  late Device device = Device();

  static final Map<String, DeviceDatabase> _instance =
  <String, DeviceDatabase>{};

  DeviceDatabase.internal(this.user, this.device);



  factory DeviceDatabase({User? user, Device? device}) {

    return _instance.putIfAbsent(device!.uid, () => DeviceDatabase.internal(user!, device));
  }

  void initState() {
    // Demonstrates configuring to the database using a file
    print('user.uid=${user.uid}');
    // _historyRef = FirebaseDatabase.instance.reference().child('users/${user.uid}/devices/${device.uid}/${device.uid}_history').orderByKey().limitToFirst(1);
    _historyRef = FirebaseDatabase.instance.reference().child('users/${user.uid}/devices/${device.uid}/${device.uid}_history');
    // _historyRef = FirebaseDatabase.instance.reference().child('users/cray/devices/${device.uid}/${device.uid}_history').orderByKey().limitToFirst(1);
    // Demonstrates configuring the database directly
    // _deviceRef = database.reference().child('users/${user.uid}/devices/${device.uid}');
    // database.reference().child('counter').once().then((DataSnapshot snapshot) {
    //   print('Connected to second database and read ${snapshot.value}');
    // });


    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
    _historyRef.keepSynced(true);

    // _historySubscription = _historyRef.onValue.listen((Event event) {
    //   error = null;
    //   _weatherHistoryValue = event.snapshot.value ?? 0;
    // }, onError: (Object o) {
    //   error = o;
    // });

    _historySubscription = _historyRef.onValue.listen((Event event) {
        error = null;
        _weatherHistoryValue = event.snapshot.value ?? 0;

    }, onError: (Object o) {
      final DatabaseError error = o as DatabaseError;
    });
  }

  DatabaseError? getError() {
    return error;
  }

  WeatherHistory getWeatherHistoryValue() {
    return _weatherHistoryValue;
  }

  DatabaseReference getLatestHistory() {
    return _historyRef;
  }

  DatabaseReference getUser() {
    return _deviceRef;
  }

  // addUser(User user) async {
  //   final TransactionResult transactionResult =
  //   await _historyRef.runTransaction((MutableData mutableData) async {
  //     mutableData.value = (mutableData.value ?? 0) + 1;
  //
  //     return mutableData;
  //   });
  //
  //   if (transactionResult.committed) {
  //     _deviceRef.push().set(<String, String>{
  //       "name": "" + user.name,
  //       "age": "" + user.age,
  //       "email": "" + user.email,
  //       "mobile": "" + user.mobile,
  //     }).then((_) {
  //       print('Transaction  committed.');
  //     });
  //   } else {
  //     print('Transaction not committed.');
  //     if (transactionResult.error != null) {
  //       print(transactionResult.error.message);
  //     }
  //   }
  // }
  //
  // void deleteUser(User user) async {
  //   await _deviceRef.child(user.id).remove().then((_) {
  //     print('Transaction  committed.');
  //   });
  // }
  //
  void updateDevice(Device device) async {
    await _deviceRef.child(device.uid).update({
      'name':  device.name,
      'readingInterval': device.readingInterval,
    }).then((_) {
      print('Transaction  committed.');
    });
  }

  void dispose() {
    // _messagesSubscription.cancel();
    if(_historySubscription != null) {
      _historySubscription.cancel();
    }
  }


}