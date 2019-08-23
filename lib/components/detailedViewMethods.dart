//Горизонтальное меню прокрутки
//Использует "хак", подсмотренный тут - https://www.youtube.com/watch?v=5KbiU-93-yU&t=1s
//создаётся PageView, который однако не рисуется, но из него берётся контроллер, который знает текущую страницу
//в виде double величины, то есть можно плавно скролить вбок
//В виджете элементы запихиваются в Stack, проходя циклом по всем менюшкам
//На основе "разницы" с текущей страницей высчитывается смещение каждого элемента
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/api/model.dart';
import 'package:memoapp/screen/TermDetail.dart';
import 'package:memoapp/screen/detailedImageScreen.dart';
import 'package:uuid/uuid.dart';

import '../AppData.dart';
import 'TermView.dart';

//Элемент горизонтально списка в меню делтального просмотра
class EdgeSelectorData {
  //Название, которое видит пользователь
  String edgeName;

  //Цвет фона этой кнопки
  Color backColor;

  //Код(строка), по которому будет происходить запрос ребра(EDGE)
  String code;

  EdgeSelectorData(String n, Color c) {
    this.edgeName = n;
    this.backColor = c;
  }
}

List<EdgeSelectorData> title = [
  new EdgeSelectorData("Audio", Colors.blue[200]),
  new EdgeSelectorData("Visual", Colors.blue[400]),
  new EdgeSelectorData("Translations", Colors.blueAccent),
  new EdgeSelectorData("Synonyms", Colors.blue[500]),
  new EdgeSelectorData("Is in other", Colors.blue[300]),
  new EdgeSelectorData("Related to", Colors.blue[500]),
  new EdgeSelectorData("Defenition", Colors.blue[700]),
  new EdgeSelectorData("Defenition of", Colors.blue),
];

//Попытка разгрузить код detailed тёрма, эдакий класс на много функций, которые можно вынести
//Понятия не имею как это дело оптимизировать, когда обращение к специфическим полям идёт
class TermDetailedViewInflateMethods {
  BuildContext context;
  List<Widget> pages;
  int viewMode = 1;
  Function getControll, getAudiosPage;
  String dropdownValue = "en";

  TermDetailedViewInflateMethods(
      {this.pages, this.getControll, this.getAudiosPage, this.context}) {}

  void fillInflateMethos(List<Function(TermInfo)> tabInflateMethods) {
    tabInflateMethods.add(makeDetailedAudios);
    tabInflateMethods.add(makeDetailedPictures);
    tabInflateMethods.add(makeDetailedTranslations);
    tabInflateMethods.add(makeDetailedSynonyms);
    tabInflateMethods.add(makeDetailedInOther);
    tabInflateMethods.add(makeDetailedRelated);
    tabInflateMethods.add(makeDetailedDefinition);
    tabInflateMethods.add(makeDetailedDefinitionOf);
  }

  void initAllPages(TermInfo visualTerm) {
    makeDetailedAudios(visualTerm);
    makeDetailedPictures(visualTerm);

    makeDetailedTranslations(visualTerm);
    makeDetailedSynonyms(visualTerm);
    makeDetailedInOther(visualTerm);
    makeDetailedRelated(visualTerm);
    makeDetailedDefinition(visualTerm);
    makeDetailedDefinitionOf(visualTerm);
  }

  loadImg(String url) {
    var img;
    img = new CachedNetworkImageProvider(url, errorListener: () {
      print("failed");
      img = CachedNetworkImageProvider(
          "https://i1.wp.com/thefrontline.org.uk/wp-content/uploads/2018/10/placeholder.jpg");
    });
    return img;
  }

  void makeTermListView(List<Widget> children, int pageIndex) {
    if (children.length > 0) {
      if (viewMode == 2) {
        pages[pageIndex] = new Column(
          children: <Widget>[
            getControll(),
            GridView.count(
              primary: false,
              shrinkWrap: true,
              // Create a grid with 2 columns. If you change the scrollDirection to
              // horizontal, this would produce 2 rows.
              crossAxisCount: 2,
              // Generate 100 Widgets that display their index in the List
              children: children,
            ),
          ],
        );
      } else {
        pages[pageIndex] = Column(
          children: <Widget>[
            getControll(),
            Column(
              children: children,
            )
          ],
        );
      }
    } else {
      pages[pageIndex] = Column(
        children: <Widget>[
          getControll(),
        ],
      );
    }
  }

  void makeDetailedAudios(TermInfo ti) {
    pages[0] = getAudiosPage();
  }

  void makeDetailedPictures(TermInfo visualTerm) {
    List<Widget> pictures = new List();

    for (int i = 0; i < visualTerm.visual.total; i++) {
      try {
        visualTerm.visual.items[i].url.contains('youtube')
            ? pictures.add(Container())
            : pictures.add(InkWell(
                onTap: () {
                  //print("TAPPPPPPP "+visualTerm.visual.items[i].url);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailedImage(visualTerm.visual.items[i])));
                },
                child: Column(
                  children: <Widget>[
                    Padding(
                      child: Container(
                        height: 200,
                        padding: new EdgeInsets.only(left: 16.0, right: 16.0),
                        decoration: new BoxDecoration(
                          boxShadow: <BoxShadow>[BoxShadow(blurRadius: 10)],
                          borderRadius: BorderRadius.circular(5),
                          border:
                              new Border.all(color: Colors.grey[400], width: 2),
                          image: new DecorationImage(
                            image: TermView.loadImg(visualTerm.visual.items[i]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(7),
                    ),
                    Padding(
                      padding: EdgeInsets.all(1),
                    )
                  ],
                ),
              ));
      } catch (e) {
        pictures.add(Container());
      }
    }

    if (pictures.length > 0) {
      pages[1] = new Column(
        children: pictures,
      );
    }
  }

  void makeDetailedDefinitionOf(TermInfo visualTerm) {
    List<Widget> definitionOf = new List();
    for (int i = 0; i < visualTerm.definitionOf.length; i++) {
      if (visualTerm.definitionOf[i].lang == dropdownValue) {
        definitionOf.add(TermView(
          term: visualTerm.definitionOf[i],
          viewMode: viewMode,
        ));
      }
    }

    makeTermListView(definitionOf, 7);
  }

  void makeDetailedDefinition(TermInfo visualTerm) {
    List<Widget> definition = new List();
    for (int i = 0; i < visualTerm.definition.length; i++) {
      if (visualTerm.definition[i].lang == dropdownValue) {
        definition.add(TermView(
          term: visualTerm.definition[i],
          viewMode: viewMode,
        ));
      }
    }

    makeTermListView(definition, 6);
  }

  void makeDetailedRelated(TermInfo visualTerm) {
    List<Widget> relatedTo = new List();
    for (int i = 0; i < visualTerm.relatedTo.length; i++) {
      if (visualTerm.relatedTo[i].lang == dropdownValue) {
        relatedTo.add(TermView(
          term: visualTerm.relatedTo[i],
          viewMode: viewMode,
        ));
      }
    }

    makeTermListView(relatedTo, 5);
  }

  void makeDetailedInOther(TermInfo visualTerm) {
    List<Widget> inOther = new List();
    for (int i = 0; i < visualTerm.isInOtherTerms.length; i++) {
      if (visualTerm.isInOtherTerms[i].lang == dropdownValue) {
        inOther.add(TermView(
          term: visualTerm.isInOtherTerms[i],
          viewMode: viewMode,
        ));
      }
    }

    makeTermListView(inOther, 4);
  }

  void makeDetailedSynonyms(TermInfo visualTerm) {
    List<Widget> synonymsView = new List();
    for (int i = 0; i < visualTerm.synonyms.length; i++) {
      if (visualTerm.synonyms[i].lang == dropdownValue) {
        synonymsView.add(TermView(
          term: visualTerm.synonyms[i],
          viewMode: viewMode,
        ));
      }
    }

    makeTermListView(synonymsView, 3);
  }

  void makeDetailedTranslations(TermInfo visualTerm) {
    List<Widget> translationView = new List();
    for (int i = 0; i < visualTerm.translations.length; i++) {
      //print(visualTerm.translations[i].lang);
      if (visualTerm.translations[i].lang == dropdownValue) {
        translationView.add(TermView(
          term: visualTerm.translations[i],
          viewMode: viewMode,
        ));
      }
    }

    makeTermListView(translationView, 2);
  }

  void initEmptyPages(TermInfo visualTerm) {
    //visualTerm.audio = term.audio;
    //term = visualTerm;
    //начальная инициализация сообщением, информирующем об отсутствии данных
    for (int i = 0; i < title.length; i++) {
      pages[i] = Align(
        child: Container(
          width: 200,
          child: Column(
            children: <Widget>[
              Text(
                " No Content for ",
                style: TextStyle(fontSize: 20, color: Colors.blue[800]),
              ),
              Text(
                title[i].edgeName + "",
                style: TextStyle(fontSize: 20, color: Colors.blue[600]),
              ),
            ],
          ),
          alignment: Alignment(0, 0),
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[BoxShadow(blurRadius: 5)]),
        ),
      );
    }

    //TODO refactor this all
    initAllPages(visualTerm);
  }
}

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
        child: Transform.scale(
          scale: 1 - delta * (delta > 0 ? 1 : -1) / 10,
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
  var res2 = await updateTerm(term.uid, tup);
  //print(res2.toString());
}
