// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, annotate_overrides, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

class LoadingScreen extends StatefulWidget {
  List<bool> popUpOn; //> 주소를 전달하고 싶어서 list 를 사용했다.
  LoadingScreen({required this.popUpOn});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Timer? _timer;

  @override
  void initState() {//> Stateful 위젯이 생성되는 순간에 딱 한 번만 호출되는 메서드.
    // TODO: implement initState
    super.initState();
    widget.popUpOn[0] = false;
    _timeOut();
  }

  void dispose() {//> Stateful 위젯을 완전히 종료 시킨다. setState() 가 멈춘다.
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }

  void _timeOut(){
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _dialog();
        _timer?.cancel(); //> 타이머 정지.
      });
    });
  }

  void _dialog(){ //> pop up window 를 띄운다.
    widget.popUpOn[0] = true; //> stateful 에서는 이렇게 데이터를 받아온다.
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("エラー"),
          content: Text("インターネット又はサーバに接続されていないです。再接続をお願い致します。"),
          actions: <Widget>[
            TextButton(
                child: Text("OK"),
                onPressed: (){
                  widget.popUpOn[0] = false;
                  _timeOut();
                  Navigator.pop(context);
                }
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height-10,
          width: MediaQuery.of(context).size.width-10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Terui',
                //'照井',
                style: TextStyle(
                  color: Colors.green,
                  //fontWeight: FontWeight.bold,
                  fontSize: 50.0,
                  fontFamily: 'Samliphopang',
                  shadows: <Shadow>[Shadow(offset: Offset(4.0, 4.0), blurRadius: 10.0, color: Colors.greenAccent)],
                ),
              ),
              Text(
                'organic',
                //'オーガニック',
                style: TextStyle(
                  color: Colors.green,
                  //fontWeight: FontWeight.bold,
                  fontSize: 50.0,
                  fontFamily: 'Samliphopang',
                  shadows: <Shadow>[Shadow(offset: Offset(4.0, 4.0), blurRadius: 10.0, color: Colors.greenAccent)],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Image.asset('images/loading.gif'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                      fontFamily: 'Samliphopang',
                    ),
                  ),
                  SizedBox(
                    width: 7.0,
                  ),
                  Center(
                    child: SpinKitDoubleBounce(
                      color: Colors.green,
                      size: 30.0,
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
