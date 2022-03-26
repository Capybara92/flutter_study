// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';

import 'package:terui_agriculture/screens/loading_screen.dart';
import 'package:terui_agriculture/screens/bottom_navi_bar_screen.dart';

class GetFirebaseDataOnce extends StatefulWidget {
  @override
  State<GetFirebaseDataOnce> createState() => _GetFirebaseDataOnceState();
}

class _GetFirebaseDataOnceState extends State<GetFirebaseDataOnce> {
  List<bool> getPopUpOn = [false]; //> 주소를 전달받고 싶어서 list 를 사용했다.

  CollectionReference goodsData = FirebaseFirestore.instance.collection('REPLACE_ME');
  FirebaseStorage goodsImage = FirebaseStorage.instance;

  Future<List<Map<String, dynamic>>> _loadImages() async {
    List<Map<String, dynamic>> files = [];

    final ListResult result = await goodsImage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      //final FullMetadata fileMeta = await file.getMetadata();
      files.add({
        "url": fileUrl,
      });
    });

    return files;
  }

  @override
  Widget build(BuildContext context) {
    //> QuerySnapshot 은 Collection 을 불러올 때.
    //> DocumentSnapshot 은 Document 를 불러올 때.

    return FutureBuilder<QuerySnapshot>(
          future: goodsData.get(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> goodsDataSnapshot) {
            return FutureBuilder(
              future: _loadImages(),
              builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> goodsImageSnapshot) {
                if (goodsDataSnapshot.connectionState == ConnectionState.waiting ||
                    goodsImageSnapshot.connectionState == ConnectionState.waiting) {
                  return LoadingScreen(popUpOn: getPopUpOn); //> 처음만 받아와서 그런건가? //> 주소를 받아와야 하나? 포인터?
                }

                if(getPopUpOn[0] == true){
                  Navigator.pop(context);
                }

                final int dataLen = (goodsImageSnapshot.data?.length ?? 0) > (goodsDataSnapshot.data?.docs.length ?? 0) ? (goodsImageSnapshot.data?.length ?? 0) : (goodsDataSnapshot.data?.docs.length ?? 0);
                return BottomNaviBarScreen(bnbGetGoodsDataSnapshot: goodsDataSnapshot, bnbGetGoodsImageSnapshot: goodsImageSnapshot, bnbDataLen: dataLen,);
                // final goodsDocs = goodsDataSnapshot.data!.docs;
                // final goodsDocsLen = goodsDataSnapshot.data!.docs.length;
                // return ListView.builder(
                //   scrollDirection: Axis.vertical,
                //   shrinkWrap: true,
                //   itemCount: goodsDocsLen,
                //   itemBuilder: (context, index) {
                //     final Map<String, dynamic> image = goodsImageSnapshot.data![index];
                //
                //     return Column(
                //       children: [
                //         ListTile(
                //           dense: false,
                //           leading: Image.network(image['url']),
                //           title: Text(goodsDocs[index]['name']),
                //           subtitle: Text("${goodsDocs[index]['price']}円"),
                //         )
                //       ],
                //     );
                //   },
                // );
              },
            );
          },
        );

  }
}