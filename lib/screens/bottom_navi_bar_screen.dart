// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, non_constant_identifier_names, no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:terui_agriculture/screens/home_screen.dart';
import 'package:terui_agriculture/screens/menu_screen.dart';
import 'package:terui_agriculture/screens/cart_screen.dart';

class BottomNaviBarScreen extends StatefulWidget {
  AsyncSnapshot<QuerySnapshot>? bnbGetGoodsDataSnapshot;
  AsyncSnapshot<List<Map<String, dynamic>>>? bnbGetGoodsImageSnapshot;
  int? bnbDataLen;
  BottomNaviBarScreen({required this.bnbGetGoodsDataSnapshot, required this.bnbGetGoodsImageSnapshot, required this.bnbDataLen});

  @override
  _BottomNaviBarScreenState createState() => _BottomNaviBarScreenState();
}

class _BottomNaviBarScreenState extends State<BottomNaviBarScreen> {

  int _bnbBottomNaviSelectedIndex = 0;

  late List<bool> bnbGoodsSelectedListOld = List.generate(widget.bnbDataLen!, (i) => false); //> widget.bnbDataLen 개의 리스트를 false 로 초기화.
  late List<bool> bnbGoodsSelectedList = List.generate(widget.bnbDataLen!, (i) => false); //> widget.bnbDataLen 개의 리스트를 false 로 초기화.
  //> Dart 는 필드 initializer 가 객체(object) 자체를 참조하는 것을 허용하지 않는다.
  //> 개체(object) 시작 생성에 대한 액세스 권한이 부여되기 전에 필드는 항상 완전히 초기화되어야 한다.
  //> initializer 는 정적(static) 및 최상위 변수에만 액세스할 수 있으며 개체(object) 자체의 인스턴스 변수에는 액세스할 수 없다.
  //> With null safety, you will be allowed to write ((late))
  //> 이러면 해당 필드는 처음 읽거나 쓸 때까지 초기화되지 않는다. 이는 반드시 개체(object) 자체가 생성된 후여야 힌다.
  List<String> bnbSelectedNameList = [];
  List<int> bnbSelectedPriceList = [];
  List<int> bnbGoodsCntList = [];
  List<double> bnbGoodsWeightList = [];
  List<int> bnbKeyValue = [];
  List<int> bnbKeyCnt = [0];

  List<String> bnbInputInfoList = ['','','','','','','','岩手県','','',];

  @override
  Widget build(BuildContext context) {

    // 이동할 페이지
    List _pages = [
      HomeScreen(),
      MenuScreen(
        mGetGoodsDataSnapshot: widget.bnbGetGoodsDataSnapshot,
        mGetGoodsImageSnapshot: widget.bnbGetGoodsImageSnapshot,
        mDataLen: widget.bnbDataLen,
        mGoodsSelectedListOld: bnbGoodsSelectedListOld,
        mGoodsSelectedList: bnbGoodsSelectedList,
        mSelectedNameList: bnbSelectedNameList,
        mSelectedPriceList: bnbSelectedPriceList,
        mGoodsCntList: bnbGoodsCntList,
        mGoodsWeightList: bnbGoodsWeightList,
        mKeyValue: bnbKeyValue,
        mKeyCnt: bnbKeyCnt,
      ),
      CartScreen(
        cGetGoodsDataSnapshot: widget.bnbGetGoodsDataSnapshot,
        cGoodsSelectedListOld: bnbGoodsSelectedListOld,
        cSelectedNameList: bnbSelectedNameList,
        cSelectedPriceList: bnbSelectedPriceList,
        cGoodsCntList: bnbGoodsCntList,
        cGoodsWeightList: bnbGoodsWeightList,
        cKeyValue: bnbKeyValue,
        cInputInfoList: bnbInputInfoList,
      ),
    ];

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true, //> body 를 appBar 위치까지 확장시킴.
        resizeToAvoidBottomInset: false,
        //appBar: _AppBar(_selectedIndex),
        body: Center(
          child: _pages[_bnbBottomNaviSelectedIndex],
        ),
        bottomNavigationBar: Container(
          height: 70,
          width: MediaQuery.of(context).size.width-10,
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
            //border: Border.all(color: Colors.green),
            borderRadius: BorderRadius.circular(0.0),
            color: Colors.green,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            onTap: _onItemTapped,
            currentIndex: _bnbBottomNaviSelectedIndex,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.green,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'ホーム', //> titie 을 쓰지 않는다.
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu),
                label: 'メニュー',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'カート',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _bnbBottomNaviSelectedIndex=index;
    });
  }

  // AppBar _AppBar(int index){
  //   if(index==0){
  //     return AppBar(title: Text('Home'),elevation: 0,);
  //   }else if(index==1){
  //     return AppBar(title: Text('Menu'),elevation: 0,);
  //   }else{
  //     return AppBar(title: Text('Cart'),elevation: 0,);
  //   }
  // }
}
