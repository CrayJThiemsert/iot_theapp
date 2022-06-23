import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';

import 'package:iot_theapp/pages/home/widget/devices_list.dart';
import 'package:iot_theapp/pages/network/choose_network.dart';

import 'package:iot_theapp/globals.dart' as globals;
import 'package:iot_theapp/pages/network/view/choose_territory_scenario_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.app}) : super(key: key);

  final FirebaseApp app;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final fb = FirebaseDatabase.instance;
  final myController = TextEditingController();
  final name = "Name2";
  final databaseReference = FirebaseDatabase.instance.ref();

  // -------------------------
  int _counter = 0;
  // late DatabaseReference _counterRef;
  // late DatabaseReference _messagesRef;
  // late StreamSubscription<DatabaseEvent> _counterSubscription;
  // late StreamSubscription<DatabaseEvent> _messagesSubscription;
  bool _anchorToBottom = false;

  String _kTestKey = 'Hello';
  String _kTestValue = 'world!';
  FirebaseException? _error;

  @override
  void initState() {
    super.initState();

    // Demonstrates configuring to the database using a file
    // _counterRef = FirebaseDatabase.instance.reference().child('counter');
    // Demonstrates configuring the database directly
    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
    // _messagesRef = database.reference().child('messages');
    // database.reference().child('counter').once().then((DataSnapshot snapshot) {
    //     print('Connected to second database and read ${snapshot.value}');
    //   }, onError: (Object o) {
    //     final FirebaseException error = o as FirebaseException;
    //     print('Error: ${error.code} ${error.message}');
    // });

    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
    // _counterRef.keepSynced(true);
    // _counterSubscription = _counterRef.onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _error = null;
    //     _counter = (event.snapshot.value ?? 0) as int;
    //   });
    // }, onError: (Object o) {
    //   final FirebaseException error = o as FirebaseException;
    //   setState(() {
    //     _error = error;
    //   });
    // });
    // _messagesSubscription =
    //     _messagesRef.limitToLast(10).onChildAdded.listen((DatabaseEvent event) {
    //       print('Child added: ${event.snapshot.value}');
    //     }, onError: (Object o) {
    //       final FirebaseException error = o as FirebaseException;
    //       print('Error: ${error.code} ${error.message}');
    //     });
  }

  @override
  Widget build(BuildContext context) {
    // final ref = fb.reference();
    // var devicesRef = ref.child("devices");

    return Scaffold(
      appBar: AppBar(
        title: Text('Iot Home Page - v.${globals.g_version}.${globals.g_buildNumber}'),
        backgroundColor: Colors.cyan[400],
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              child: Text('Add New Device'),
              style: ElevatedButton.styleFrom(
                primary: Colors.cyan[400],
                // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                // textStyle: TextStyle(
                //     fontSize: 30,
                //     fontWeight: FontWeight.bold)
              ),
              onPressed: () {
                // Navigate to add new device page
                Navigator.push(
                  context,
                  // MaterialPageRoute(builder: (context) => ChooseNetworkPage()),
                  MaterialPageRoute(builder: (context) => ChooseTerritoryScenarioPage()),
                );
              },
            ),
          ),
          // ElevatedButton(onPressed: () {
          //   print('get data name2 once...');
          //   ref.child("Name2").once().then((DataSnapshot data){
          //     print('value=${data.value}');
          //     print('key=${data.key}');
          //     // setState(() {
          //     //   retrievedName = data.value;
          //     // });
          //   });
          // }, child: Text('Get sample data')),

          DevicesList(),

        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   // onPressed: _increment,
      //   onPressed: () {
      //     var post = Post('Hello', 'Cray');
      //     post.setId(savePost(post));
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();

    // _messagesSubscription.cancel();
    // _counterSubscription.cancel();
  }
}