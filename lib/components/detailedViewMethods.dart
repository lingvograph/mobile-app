//Горизонтальное меню прокрутки
//Использует "хак", подсмотренный тут - https://www.youtube.com/watch?v=5KbiU-93-yU&t=1s
//создаётся PageView, который однако не рисуется, но из него берётся контроллер, который знает текущую страницу
//в виде double величины, то есть можно плавно скролить вбок
//В виджете элементы запихиваются в Stack, проходя циклом по всем менюшкам
//На основе "разницы" с текущей страницей высчитывается смещение каждого элемента
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/api/model.dart';
import 'package:memoapp/screen/TermDetail.dart';
import 'package:uuid/uuid.dart';

import '../AppData.dart';

//Элемент горизонтально списка в меню делтального просмотра
class EdgeSelectorData {
  //Название, которое видит пользователь
  String edgeName;

  //Цвет фона этой кнопки
  Color backColor;

  //Код(строка), по которому будет происходить запрос ребра(EDGE)
  String code;

  EdgeSelectorData(String n, Color c, String co) {
    this.edgeName = n;
    this.backColor = c;
    this.code = co;
  }
}
List<EdgeSelectorData> title = [
  new EdgeSelectorData("Audio", Colors.blue[200], "audio"),
  new EdgeSelectorData("Visual", Colors.blue[400], "visual"),
  new EdgeSelectorData("Translations", Colors.blueAccent, "translated_as"),
  new EdgeSelectorData("Is in other", Colors.blue[300], "in"),
  new EdgeSelectorData("Related to", Colors.blue[500], "related"),
  new EdgeSelectorData("Defenition", Colors.blue[700], "def"),
  new EdgeSelectorData("Defenition of", Colors.blue, "def_of"),
];

class HorizontalEdgeMenu extends StatelessWidget {
  var currentPage;

  HorizontalEdgeMenu(this.currentPage);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<Widget> cardList = new List();

    for (var i = 0; i < title.length; i++) {
      var delta = i - currentPage;

      var cardItem = Positioned(
        top: 3 * delta * (delta > 0 ? 1 : -1),
        left: width / 2 +
            100 * sqrt(delta * (delta > 0 ? 1 : -1)) * (delta > 0 ? 1 : -1) -
            title[i].edgeName.length / 2 * 10,
        //textDirection: TextDirection.rtl,
        child: Transform.scale(scale: 1-delta * (delta > 0 ? 1 : -1)/10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(color: title[i].backColor, boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(3.0, 6.0),
                    blurRadius: 20.0)
              ]),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  //aspectRatio: gar,
                  child: Text(title[i].edgeName),
                ),
              ),
            ),
          ),
        ),
      );

      delta > 0 ? cardList.insert(0, cardItem) : cardList.add(cardItem);
      //cardList[delta]==null?cardList[i]=cardItem:cardList[i+1]=cardItem;
    }
    return Container(
        height: 70,
        child: Stack(
          children: cardList,
        ));
  }
}
void openCamera(TermInfo term) async {
  File cameraFile;
  print("camera open!");
  cameraFile = await ImagePicker.pickImage(
    source: ImageSource.camera,
    //maxHeight: 50.0,
    //maxWidth: 50.0,
  );
  if (cameraFile != null) {
    //print("You selected camera image : " + cameraFile.path);
    uploadPhoto(cameraFile, term);
  } else {
    print("no data");
  }
}

void openGalery(TermInfo term) async {
  File galleryFile;

  galleryFile = await ImagePicker.pickImage(
    source: ImageSource.gallery,
    // maxHeight: 50.0,
    // maxWidth: 50.0,
  );
  if (galleryFile != null) {
    //print("You selected gallery image : " + galleryFile.path);
    uploadPhoto(galleryFile, term);
  } else {
    print("no data");
  }
  //setState(() {});
}

void uploadPhoto(File f, TermInfo term) async {
  List<int> bytes = f.readAsBytesSync();

  // TODO link to current term
  var uuid = new Uuid();
  final user = appData.appState.user;
  String datauid = uuid.v4();
  final remotePath = "user/${user.uid}/visual/${datauid}.jpeg";

  var res = await upload("$remotePath", 'visual/jpeg', bytes);
  TermUpdate tup = new TermUpdate();
  tup.imageUid = res.uid;
  //print(tup.imageUid);
  var res2 = await upadteTerm(term.uid, tup);
  //print(res2.toString());
}