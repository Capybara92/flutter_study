// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'dart:convert'; //> json 사용할 때 필요

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class CartScreen extends StatefulWidget {
  AsyncSnapshot<QuerySnapshot>? cGetGoodsDataSnapshot;
  List<bool>? cGoodsSelectedListOld;
  List<String>? cSelectedNameList;
  List<int>? cSelectedPriceList;
  List<int>? cGoodsCntList;
  List<double>? cGoodsWeightList;
  List<int>? cKeyValue;
  List<String>? cInputInfoList;

  CartScreen({
    required this.cGetGoodsDataSnapshot,
    required this.cGoodsSelectedListOld,
    required this.cSelectedNameList,
    required this.cSelectedPriceList,
    required this.cGoodsCntList,
    required this.cGoodsWeightList,
    required this.cKeyValue,
    required this.cInputInfoList,
  });

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  double _goodsWeightSum = 0.0;
  int _goodsCntSum = 0;
  int _goodsPriceSum = 0;

  int _deliveryPrice = 0;
  int _orderPrice = 0;
  bool _showSpinner = false;
  List<String> goodsListToString = [];

  final List<String> _prefectureList = [
    '北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県', '茨城県', '栃木県', '群馬県', '埼玉県',
    '千葉県', '東京都', '神奈川県', '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県', '静岡県',
    '愛知県', '三重県', '滋賀県', '京都府', '大阪府', '兵庫県', '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県',
    '広島県', '山口県', '徳島県', '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県', '熊本県', '大分県',
    '宮崎県', '鹿児島県', '沖縄県',
  ];
  late String _selectedPrefecture = widget.cInputInfoList![7];

  final _formKey = GlobalKey<FormState>();
  void _tryValidation(){
    final isValid = _formKey.currentState!.validate(); //> 이것으로 validation 을 동작시킬 수 있다.
    if(isValid){
      _formKey.currentState!.save(); //> 이 값들을 저장할 수 있다.
      //> save 메서드가 호출되면 Form 전체의 state 값을 저장하게 되는데,
      //> 이 과정에서 모든 TextField 가 가지고 있는 onSaved 라는 메소드를 작동시키게 된다.
      //> 그래서 우리는 각 TextFormField 에서 onSaved 메소드를 추가해 주어야 한다.
    }
  }
  bool _isInputInfoOk = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _goodsPriceCal();
    _deliveryPriceCal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //> 키보드가 화면을 밀고 올라가는 것을 안함. 화면은 그대로 유지한 상태로 키보드가 올라옴
      appBar: AppBar(
        title: Text(
          'Cart',
          style: TextStyle(
            color: Colors.green,
            fontFamily: 'Samliphopang',
            fontSize: 40.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 10.0,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
          child: _checkSelected(),
        ),
      ),
    );
  }

  Widget _checkSelected() {
    if (widget.cSelectedNameList!.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); //> 화면을 누르면 키보드가 사라진다
          setState(() {
            _goodsPriceCal();
            _deliveryPriceCal();
          });
        },
        child: SingleChildScrollView(
          child: Form(//> TextFormField 의 validation 을 검사하기 위해서 필요하다.
            key: _formKey, //> 글로벌 키를 가져와야 한다.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //> 가로기준 (Column 은 가로기준, Row 의 경우는 세로기준이다.)
              //mainAxisAlignment: MainAxisAlignment.start, //> 세로기준
              children: [
                Text(
                  '商品',
                  style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'Samliphopang',
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  height: MediaQuery.of(context).size.height - 600,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        //> 박스의 입체갑을 위해서 쓴다.
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), //> 투명도를 0.3으로 한다.
                          blurRadius: 10, //> 그림자 테두리를 흐리게 제어.
                          spreadRadius: 3, //> 그림자 두께 제어.
                        ),
                      ]),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: widget.cSelectedNameList!.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${index+1}'),
                              SizedBox(
                                height: 60.0,
                                width: 100.0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(widget.cSelectedNameList![index]),
                                    Text("${widget.cSelectedPriceList![index]}円/${widget.cGoodsWeightList![index]}kg")
                                  ],
                                ),
                              ),
                              Text(
                                ' X ',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                height: 40.0,
                                width: 63.0,
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    //> TextFormField 에 포커스가 들어갈 때 발생하는 이벤트
                                    setState(() {
                                      _goodsPriceCal();
                                      _deliveryPriceCal();
                                    });
                                  },
                                  child: TextFormField(
                                    key: ValueKey(widget.cKeyValue![index]),
                                    keyboardType: TextInputType.number,
                                    initialValue: '${widget.cGoodsCntList![index]}',
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly, //> 숫자만 입력하게 해준다.
                                      LengthLimitingTextInputFormatter(2), //> 2자리만 입력 가능하게 해준다.
                                    ],
                                    validator: (value){
                                      if(value!.isEmpty || int.parse(value)==0){
                                        _isInputInfoOk = false;
                                        return '1個以上';
                                      }else{
                                        return null;
                                      }
                                    },
                                    onSaved: (value){ //> 사용자가 입력한 밸류값을 저장하는 기능
                                      widget.cGoodsCntList![index] = int.parse(value!);
                                    },
                                    onChanged: (value){ //> 사용자가 텍스트에 입력한 값을 가져온다
                                      try{ //> 데이터의 입력이 있을 경우
                                        widget.cGoodsCntList![index] = int.parse(value);
                                      }
                                      catch(e){ //> 데이터의 입력이 없을 경우
                                        widget.cGoodsCntList![index] = 0;
                                      }
                                    },
                                    textAlign: TextAlign.center, //> 입력 텍스트를 중앙에 배치.
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        // borderSide: BorderSide(
                                        //     color: Palette.textColor1,
                                        // ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                      ),
                                      focusedBorder: OutlineInputBorder( //> 클릭을 해도 사각형이 유지되게 한다.
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                        ),
                                      ),
                                      hintText: '  数量',  //> 입력전에 보여지는 텍스트
                                      hintStyle: TextStyle(
                                        fontSize: 13.0,
                                      ),
                                      contentPadding:
                                          EdgeInsets.all(10), //> 상자의 폭을 조절한다.
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '個  ',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.black,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    for(int i=0; i<widget.cGoodsSelectedListOld!.length; i++){
                                      if(widget.cSelectedNameList![index]==widget.cGetGoodsDataSnapshot!.data!.docs[i]['name']){
                                        widget.cGoodsSelectedListOld![i] = false;
                                        break;
                                      }
                                    }
                                    widget.cSelectedNameList!.removeAt(index); //> remove 만 하면 안된다. 왜?...
                                    widget.cSelectedPriceList!.removeAt(index); //> removeWhere 도 하나의 방법중 하나란다.
                                    widget.cGoodsCntList!.removeAt(index);
                                    widget.cGoodsWeightList!.removeAt(index);
                                    widget.cKeyValue!.removeAt(index);
                                    _goodsPriceCal();
                                    _deliveryPriceCal();
                                  });
                                },
                                child: Text('削除'),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.redAccent,
                                  //> Elevated 에서는 배경색을 담당함.
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), //> 버튼의 모양을 디자인
                                  ),
                                  elevation: 0.0, //> 버튼의 입체갑을 조절(버튼의 그림자 조절)
                                ),
                              ),
                              //> delete button
                            ],
                          ),
                          Divider(
                            height: 10.0,
                            thickness: 1.0,
                            indent: 10.0,
                            endIndent: 10.0,
                            color: Colors.black,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                //> selected goods list
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('総量重 : ${_goodsWeightSum.toStringAsFixed(2)}kg'), //> 소수점 2번째 자리까지만(3번째는 반올림)
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('総数量 : $_goodsCntSum個'),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('金額 : $_goodsPriceSum円'),
                  ],
                ),
                //> goods price
                Text(
                  '情報入力',
                  style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'Samliphopang',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 75.0,
                            child: Text('電話番号', style: TextStyle(letterSpacing: 2.0),),
                          ),
                          Text(' :   '),
                          SizedBox(
                            height: 40.0,
                            width: 65.0,
                            child: Focus(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                initialValue: widget.cInputInfoList![0],
                                validator: (value){
                                  if(value!.isEmpty){
                                    _isInputInfoOk = false;
                                    return '';
                                  }else{
                                    return null;
                                  }
                                },
                                onSaved: (value){ //> 사용자가 입력한 밸류값을 저장하는 기능
                                  widget.cInputInfoList![0] = value!;
                                },
                                onChanged: (value){ //> 사용자가 텍스트에 입력한 값을 가져온다
                                  try{ //> 데이터의 입력이 있을 경우
                                    widget.cInputInfoList![0] = value;
                                  }
                                  catch(e){ //> 데이터의 입력이 없을 경우
                                    widget.cInputInfoList![0] = '';
                                  }
                                },
                                style: TextStyle(fontSize: 15.0,),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                  ),
                                  focusedBorder: OutlineInputBorder( //> 클릭을 해도 사각형이 유지되게 한다.
                                    borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                  ),
                                  contentPadding:
                                      EdgeInsets.all(10), //> 상자의 폭을 조절한다.
                                ),
                              ),
                            ),
                          ),
                          Text('  -  '),
                          SizedBox(
                            height: 40.0,
                            width: 65.0,
                            child: Focus(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                initialValue: widget.cInputInfoList![1],
                                validator: (value){
                                  if(value!.isEmpty){
                                    _isInputInfoOk = false;
                                    return '';
                                  }else{
                                    return null;
                                  }
                                },
                                onSaved: (value){ //> 사용자가 입력한 밸류값을 저장하는 기능
                                  widget.cInputInfoList![1] = value!;
                                },
                                onChanged: (value){ //> 사용자가 텍스트에 입력한 값을 가져온다
                                  try{ //> 데이터의 입력이 있을 경우
                                    widget.cInputInfoList![1] = value;
                                  }
                                  catch(e){ //> 데이터의 입력이 없을 경우
                                    widget.cInputInfoList![1] = '';
                                  }
                                },
                                style: TextStyle(fontSize: 15.0,),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                  ),
                                  focusedBorder: OutlineInputBorder( //> 클릭을 해도 사각형이 유지되게 한다.
                                    borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                  ),
                                  contentPadding:
                                  EdgeInsets.all(10), //> 상자의 폭을 조절한다.
                                ),
                              ),
                            ),
                          ),
                          Text('  -  '),
                          SizedBox(
                            height: 40.0,
                            width: 65.0,
                            child: Focus(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                initialValue: widget.cInputInfoList![2],
                                validator: (value){
                                  if(value!.isEmpty){
                                    _isInputInfoOk = false;
                                    return '';
                                  }else{
                                    return null;
                                  }
                                },
                                onSaved: (value){ //> 사용자가 입력한 밸류값을 저장하는 기능
                                  widget.cInputInfoList![2] = value!;
                                },
                                onChanged: (value){ //> 사용자가 텍스트에 입력한 값을 가져온다
                                  try{ //> 데이터의 입력이 있을 경우
                                    widget.cInputInfoList![2] = value;
                                  }
                                  catch(e){ //> 데이터의 입력이 없을 경우
                                    widget.cInputInfoList![2] = '';
                                  }
                                },
                                style: TextStyle(fontSize: 15.0,),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                  ),
                                  focusedBorder: OutlineInputBorder( //> 클릭을 해도 사각형이 유지되게 한다.
                                    borderRadius: BorderRadius.all(Radius.circular(5.0),),
                                  ),
                                  contentPadding:
                                  EdgeInsets.all(10), //> 상자의 폭을 조절한다.
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 75.0,
                            child: Text('E-mail', style: TextStyle(letterSpacing: 3.0),),
                          ),
                          Text(' :   '),
                          SizedBox(
                            height: 40.0,
                            width: 230.0,
                            child: Focus(
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                initialValue: widget.cInputInfoList![3],
                                validator: (value){
                                  if(value!.isEmpty || !value.contains('@')){
                                    _isInputInfoOk = false;
                                    return '"@"を入れたE-mailを入力してください。';
                                  }else{
                                    return null;
                                  }
                                },
                                onSaved: (value){ //> 사용자가 입력한 밸류값을 저장하는 기능
                                  widget.cInputInfoList![3] = value!;
                                },
                                onChanged: (value){ //> 사용자가 텍스트에 입력한 값을 가져온다
                                  try{ //> 데이터의 입력이 있을 경우
                                    widget.cInputInfoList![3] = value;
                                  }
                                  catch(e){ //> 데이터의 입력이 없을 경우
                                    widget.cInputInfoList![3] = '';
                                  }
                                },
                                style: TextStyle(fontSize: 15.0,),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder( //> 클릭을 해도 사각형이 유지되게 한다.
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  contentPadding:
                                      EdgeInsets.all(10), //> 상자의 폭을 조절한다.
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 75.0,
                            child: Text('お名前', style: TextStyle(letterSpacing: 8.0),),
                          ),
                          Text(' :   '),
                          SizedBox(
                            height: 40.0,
                            width: 230.0,
                            child: Focus(
                              child: TextFormField(
                                keyboardType: TextInputType.name,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                initialValue: widget.cInputInfoList![4],
                                validator: (value){
                                  if(value!.isEmpty){
                                    _isInputInfoOk = false;
                                    return '';
                                  }else{
                                    return null;
                                  }
                                },
                                onSaved: (value){ //> 사용자가 입력한 밸류값을 저장하는 기능
                                  widget.cInputInfoList![4] = value!;
                                },
                                onChanged: (value){ //> 사용자가 텍스트에 입력한 값을 가져온다
                                  try{ //> 데이터의 입력이 있을 경우
                                    widget.cInputInfoList![4] = value;
                                  }
                                  catch(e){ //> 데이터의 입력이 없을 경우
                                    widget.cInputInfoList![4] = '';
                                  }
                                },
                                style: TextStyle(fontSize: 15.0,),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  hintText: '必ず口座と同じ名前を入力', //> 입력전에 보여지는 텍스트
                                  hintStyle: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.red,
                                  ),
                                  contentPadding:
                                      EdgeInsets.all(10), //> 상자의 폭을 조절한다.
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 75.0,
                            child: Text('郵便番号', style: TextStyle(letterSpacing: 2.0),),
                          ),
                          Text(' :   '),
                          SizedBox(
                            height: 40.0,
                            width: 105.0,
                            child: Focus(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                initialValue: widget.cInputInfoList![5],
                                validator: (value){
                                  if(value!.isEmpty){
                                    _isInputInfoOk = false;
                                    return '';
                                  }else{
                                    return null;
                                  }
                                },
                                onSaved: (value){ //> 사용자가 입력한 밸류값을 저장하는 기능
                                  widget.cInputInfoList![5] = value!;
                                },
                                onChanged: (value){ //> 사용자가 텍스트에 입력한 값을 가져온다
                                  try{ //> 데이터의 입력이 있을 경우
                                    widget.cInputInfoList![5] = value;
                                  }
                                  catch(e){ //> 데이터의 입력이 없을 경우
                                    widget.cInputInfoList![5] = '';
                                  }
                                },
                                style: TextStyle(fontSize: 15.0,),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder( //> 클릭을 해도 사각형이 유지되게 한다.
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  contentPadding:
                                      EdgeInsets.all(10), //> 상자의 폭을 조절한다.
                                ),
                              ),
                            ),
                          ),
                          Text('  -  '),
                          SizedBox(
                            height: 40.0,
                            width: 105.0,
                            child: Focus(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                initialValue: widget.cInputInfoList![6],
                                validator: (value){
                                  if(value!.isEmpty){
                                    _isInputInfoOk = false;
                                    return '';
                                  }else{
                                    return null;
                                  }
                                },
                                onSaved: (value){ //> 사용자가 입력한 밸류값을 저장하는 기능
                                  widget.cInputInfoList![6] = value!;
                                },
                                onChanged: (value){ //> 사용자가 텍스트에 입력한 값을 가져온다
                                  try{ //> 데이터의 입력이 있을 경우
                                    widget.cInputInfoList![6] = value;
                                  }
                                  catch(e){ //> 데이터의 입력이 없을 경우
                                    widget.cInputInfoList![6] = '';
                                  }
                                },
                                style: TextStyle(fontSize: 15.0,),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder( //> 클릭을 해도 사각형이 유지되게 한다.
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  contentPadding:
                                  EdgeInsets.all(10), //> 상자의 폭을 조절한다.
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 75.0,
                            child: Text('住所', style: TextStyle(letterSpacing: 10.0),),
                          ),
                          Text(' :   '),
                          SizedBox(
                            height: 40.0,
                            width: 90.0,
                            child: DropdownButton(
                              value: _selectedPrefecture,
                              items: _prefectureList.map((value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPrefecture = value.toString();
                                  widget.cInputInfoList![7] = _selectedPrefecture;
                                  _deliveryPriceCal();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 15.0,
                          ),
                          SizedBox(
                            height: 40.0,
                            width: 305.0,
                            child: Focus(
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                initialValue: widget.cInputInfoList![8],
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                validator: (value){
                                  if(value!.isEmpty){
                                    _isInputInfoOk = false;
                                    return '';
                                  }else{
                                    return null;
                                  }
                                },
                                onSaved: (value){ //> 사용자가 입력한 밸류값을 저장하는 기능
                                  widget.cInputInfoList![8] = value!;
                                },
                                onChanged: (value){ //> 사용자가 텍스트에 입력한 값을 가져온다
                                  try{ //> 데이터의 입력이 있을 경우
                                    widget.cInputInfoList![8] = value;
                                  }
                                  catch(e){ //> 데이터의 입력이 없을 경우
                                    widget.cInputInfoList![8] = '';
                                  }
                                },
                                style: TextStyle(fontSize: 15.0,),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder( //> 클릭을 해도 사각형이 유지되게 한다.
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  hintText: '庁、郡、市、区　/　町、丁目、番地・号',  //> 입력전에 보여지는 텍스트
                                  hintStyle: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                  contentPadding: EdgeInsets.all(10), //> 상자의 폭을 조절한다.
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 15.0,
                          ),
                          SizedBox(
                            height: 40.0,
                            width: 305.0,
                            child: Focus(
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                initialValue: widget.cInputInfoList![9],
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                validator: (value){
                                  if(value!.isEmpty){
                                    _isInputInfoOk = false;
                                    return '';
                                  }else{
                                    return null;
                                  }
                                },
                                onSaved: (value){ //> 사용자가 입력한 밸류값을 저장하는 기능
                                  widget.cInputInfoList![9] = value!;
                                },
                                onChanged: (value){ //> 사용자가 텍스트에 입력한 값을 가져온다
                                  try{ //> 데이터의 입력이 있을 경우
                                    widget.cInputInfoList![9] = value;
                                  }
                                  catch(e){ //> 데이터의 입력이 없을 경우
                                    widget.cInputInfoList![9] = '';
                                  }
                                },
                                style: TextStyle(fontSize: 15.0,),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder( //> 클릭을 해도 사각형이 유지되게 한다.
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  hintText: '建物名、棟、室など',  //> 입력전에 보여지는 텍스트
                                  hintStyle: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                  contentPadding: EdgeInsets.all(10), //> 상자의 폭을 조절한다.
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //> input address information
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('配達料金 : $_deliveryPrice円'),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('総金額 : $_orderPrice円'),
                  ],
                ),
                //> delivery price, sum price
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        _tryValidation();

                        if(_isInputInfoOk){
                          _isInputInfoOk = true;
                          _dialog();
                        }else{
                          _isInputInfoOk = true;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('入力の間違いがあります。(赤ライン)'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      child: Text('注文依頼'),),
                  ],
                ),
                //> order button
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: Text('選択された商品がありません。'),
    );
  }

  void _goodsPriceCal(){
    _goodsWeightSum = 0.0;
    _goodsCntSum = 0;
    _goodsPriceSum = 0;
    for(int i=0; i<widget.cSelectedNameList!.length; i++){
      _goodsWeightSum += (widget.cGoodsWeightList![i] * widget.cGoodsCntList![i].toDouble());
      _goodsCntSum += widget.cGoodsCntList![i];
      _goodsPriceSum += (widget.cSelectedPriceList![i] * widget.cGoodsCntList![i]);
    }
  }

  void _deliveryPriceCal(){
    if(_selectedPrefecture=='北海道'){
      _deliveryPrice = 4000;
    }else if(_selectedPrefecture=='青森県'){
      _deliveryPrice = 3000;
    }else if(_selectedPrefecture=='岩手県'){
      _deliveryPrice = 2000;
    }else{
      _deliveryPrice = 1000;
    }

    _orderPrice = _deliveryPrice + _goodsPriceSum;
  }

  void _dialog(){ //> pop up window 를 띄운다.
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("間違った情報はないでしょうか？"),
          content: Text("送金予定日に入金額と口座の名前を確認致します。入金額と口座の名前が一致したら"
              "依頼した商品を情報通りにお送り致します。"),
          actions: <Widget>[
            TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                }
            ),
            TextButton(
                child: Text("OK"),
                onPressed: () async{
                  Navigator.pop(context);
                  setState(() {
                    _showSpinner = true;
                  });
                  _makeGoodsListToString();
                  await _sendEmail();
                  setState(() {
                    _showSpinner = false;
                  });
                }
            ),
          ],
        );
      },
    );
  }

  void _makeGoodsListToString(){
    goodsListToString.clear();
    for(int i=0; i<widget.cSelectedNameList!.length; i++){
      goodsListToString.add('${i+1}. ' + widget.cSelectedNameList![i] + ' : ' + '${widget.cGoodsCntList![i]}' + '個.');
    }
  }

  Future _sendEmail() async{
    const serviceId = 'REPLACE_ME';
    const templateId = 'REPLACE_ME';
    const userId = 'REPLACE_ME';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params':{
          'REPLACE_ME': widget.cInputInfoList![0],
          'REPLACE_ME': widget.cInputInfoList![1],
          'REPLACE_ME': widget.cInputInfoList![2],
          'REPLACE_ME': widget.cInputInfoList![3],
          'REPLACE_ME': widget.cInputInfoList![4],
          'REPLACE_ME': goodsListToString,
          'REPLACE_ME': _goodsCntSum,
          'REPLACE_ME': _orderPrice,
          'REPLACE_ME': widget.cInputInfoList![5],
          'REPLACE_ME': widget.cInputInfoList![6],
          'REPLACE_ME': widget.cInputInfoList![7],
          'REPLACE_ME': widget.cInputInfoList![8],
          'REPLACE_ME': widget.cInputInfoList![9],
        },
      }),
    );

    if(response.body=='OK'){
      _infoReset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('注文依頼を成功しました。'),
          backgroundColor: Colors.green,
        ),
      );
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('注文依頼失敗。インターネット又はサーバに問題があります。'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _infoReset(){
    setState(() {
      for(int i=0; i<widget.cGoodsSelectedListOld!.length; i++){
        widget.cGoodsSelectedListOld![i] = false;
      }
      widget.cSelectedNameList!.clear();
      widget.cSelectedPriceList!.clear();
      widget.cGoodsCntList!.clear();
      widget.cGoodsWeightList!.clear();
      widget.cKeyValue!.clear();
      widget.cInputInfoList![0]='';
      widget.cInputInfoList![1]='';
      widget.cInputInfoList![2]='';
      widget.cInputInfoList![3]='';
      widget.cInputInfoList![4]='';
      widget.cInputInfoList![5]='';
      widget.cInputInfoList![6]='';
      widget.cInputInfoList![7]='岩手県';
      widget.cInputInfoList![8]='';
      widget.cInputInfoList![9]='';
    });
  }
}