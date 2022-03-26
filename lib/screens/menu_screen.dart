// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuScreen extends StatefulWidget {
  AsyncSnapshot<QuerySnapshot>? mGetGoodsDataSnapshot;
  AsyncSnapshot<List<Map<String, dynamic>>>? mGetGoodsImageSnapshot;
  int? mDataLen;
  List<bool>? mGoodsSelectedListOld;
  List<bool>? mGoodsSelectedList;
  List<String>? mSelectedNameList;
  List<int>? mSelectedPriceList;
  List<int>? mGoodsCntList;
  List<double>? mGoodsWeightList;
  List<int>? mKeyValue;
  List<int>? mKeyCnt;

  MenuScreen({
    required this.mGetGoodsDataSnapshot,
    required this.mGetGoodsImageSnapshot,
    required this.mDataLen,
    required this.mGoodsSelectedListOld,
    required this.mGoodsSelectedList,
    required this.mSelectedNameList,
    required this.mSelectedPriceList,
    required this.mGoodsCntList,
    required this.mGoodsWeightList,
    required this.mKeyValue,
    required this.mKeyCnt,
  });

  @override
  _MenuScreenState createState() => _MenuScreenState(); //> argument 로 보내는 방법, parameter 로 보내는 방법이 다르다.
}                                                       //> parameter 로 보내는 것은 생성자 없이 파라미터만 넣는 것.

class _MenuScreenState extends State<MenuScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu',
          style: TextStyle(
            color: Colors.green,
            fontFamily: 'Samliphopang',
            fontSize: 40.0,
          ),
        ),
        backgroundColor : Colors.white,
        elevation: 10.0,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0, /*bottom: 80.0*/),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: widget.mDataLen,
          itemBuilder: (context, index) {
            return Column(
              children: [
                _stockCheck(index),
                Divider(
                  height: 30.0,
                  thickness: 1.0,
                  color: Colors.black,
                ),
                SizedBox(
                  height: _setHeight(index),
                ),
              ],
            );
          },
        ),
        //> Goods list
      ),
      floatingActionButton: Container(
        height: 70,
        width: 70,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(40),
        ),
        child: FloatingActionButton(
          onPressed: (){
            setState(() {
              // widget.mSelected = _select; //> 이렇게 하면 주소로 전달이 안된다. 왜 안되는지는 모르겠다...
              _sendSelected();
              _inputCartPopup();
            });
          },
          tooltip: 'カートに入れる',
          child: Icon(Icons.shopping_cart),
          foregroundColor: Colors.green,
          backgroundColor: Colors.white,
          elevation: 10.0,
        ),
      ),
    );
  }

  double _setHeight(int idx){
    if(widget.mDataLen==(idx+1)){
      return 80.0;
    }

    return 0.0;
  }

  void _sendSelected(){
    for(int i=0; i<widget.mGoodsSelectedList!.length; i++){ //> 각 클래스에 대해 수동으로 구현되지 않는 한 Dart 에는 객체(깊은 또는 얕은)를 복사하는 기능이 없다.
      if(widget.mGoodsSelectedList![i]==true){ //> Dart 는 메모리 에 대한 액세스를 허용하지 않으며 클래스의 협력 없이 객체를 단순 복사할 방법이 없다.
        if(widget.mGoodsSelectedListOld![i]==false){//> 새 리스트 추가
          widget.mGoodsSelectedListOld![i] = true;
          widget.mSelectedNameList!.add(widget.mGetGoodsDataSnapshot!.data!.docs[i]['REPLACE_ME']);
          widget.mSelectedPriceList!.add(widget.mGetGoodsDataSnapshot!.data!.docs[i]['REPLACE_ME']);
          widget.mGoodsCntList!.add(1);
          widget.mGoodsWeightList!.add(widget.mGetGoodsDataSnapshot!.data!.docs[i]['REPLACE_ME'].toDouble()); //> firebase 에 int 형 밖에 없어서 int 를 받아서 double 로 변환
          widget.mKeyCnt![0]++; //> keyValue
          widget.mKeyValue!.add(widget.mKeyCnt![0]);
        }else{//> 기존 리스트의 수량 1 추가
          for(int k=0; k<widget.mSelectedNameList!.length; k++){
            if(widget.mGetGoodsDataSnapshot!.data!.docs[i]['REPLACE_ME']==widget.mSelectedNameList![k]){
              widget.mGoodsCntList![k] += 1;
              break;
            }
          }
        }
      }
    }
  }

  void _inputCartPopup(){ //> pop up window 를 띄운다.
    showDialog(
      context: context,
      builder: (_) {
        if(widget.mGoodsSelectedList!.contains(true)){ //> _select 가 true 를 포함할 경우.
          for(int i=0; i<widget.mGoodsSelectedList!.length; i++){
            widget.mGoodsSelectedList![i]=false;
          }
          //widget.mGoodsSelectedList = List.generate(widget.mDataLen!, (i) => false); //> 이렇게 하면 초기화가 안된다.

          return AlertDialog(
            title: Text("完了"),
            content: Text("カートに商品を入れました。注文はカートでお願い致します。"),
            actions: <Widget>[
              TextButton(
                  child: Text("OK"),
                  onPressed: (){
                    Navigator.pop(context);
                  }
              ),
            ],
          );
        }

        return AlertDialog(
          title: Text("失敗"),
          content: Text("商品を選択してください。"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: (){
                Navigator.pop(context);
              }
            ),
          ],
        );
      },
    );
  }

  Widget _stockCheck(int index){
    final goodsDocs = widget.mGetGoodsDataSnapshot!.data!.docs;
    final Map<String, dynamic> image = widget.mGetGoodsImageSnapshot!.data![index];

    if(goodsDocs[index]['REPLACE_ME']<=0){
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 120.0,
            width: 270.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(40),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              dense: false,
              leading: Image.network(image['REPLACE_ME'], height: 100.0, width: 100.0,),
              title: Text(goodsDocs[index]['REPLACE_ME']),
              subtitle: Text("${goodsDocs[index]['REPLACE_ME']}円/${goodsDocs[index]['REPLACE_ME']}kg"),
              tileColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Text(
            '売り切れ',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }else{
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 120.0,
            width: 270.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(40),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              dense: false,
              leading: Image.network(image['REPLACE_ME'], height: 100.0, width: 100.0,),
              title: Text(goodsDocs[index]['REPLACE_ME']),
              subtitle: Text("${goodsDocs[index]['REPLACE_ME']}円(税込)/${goodsDocs[index]['REPLACE_ME']}kg"),
              tileColor: widget.mGoodsSelectedList![index] ? Colors.lightGreen : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              onTap: (){
                _tileState(index);
              },
              trailing: Icon(
                Icons.check,
                color: Colors.white,
                size: 50.0,
              ),
            ),
          ),
        ],
      );
    }
  }

  void _tileState(int idx){
    setState(() {
      widget.mGoodsSelectedList![idx] = !widget.mGoodsSelectedList![idx];
    });
  }
}

