// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:terui_agriculture/get_firebase_data_once.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); //> from firebase core
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terui Agriculture',
      // theme: ThemeData(
      //   primarySwatch: Colors.red,
      // ),
      home: GetFirebaseDataOnce(),
    );
  }
}
