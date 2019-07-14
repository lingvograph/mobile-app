import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/api/model.dart';
import 'package:memoapp/components/Loading.dart';
import 'package:memoapp/components/TermView.dart';
import 'package:memoapp/components/AudioList.dart';
import 'package:memoapp/components/addContentButton.dart';
import 'package:memoapp/screen/recordaudioscreen.dart';

//import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_player/youtube_player.dart';

typedef SearchCallback = void Function(String searchString);

class TermDetail extends StatefulWidget {
  String id;

  TermDetail(this.id);

  @override
  State<StatefulWidget> createState() {
    return new TermDetailState(id);
  }
}

List<IconData> images = [
  Icons.looks_one,
  Icons.looks_two,
  Icons.looks_3,
  Icons.looks_4,
];

List<EdgeSelectorData> title = [
  new EdgeSelectorData("Audio", Colors.grey[300], "audio"),
  new EdgeSelectorData("Visual", Colors.grey[400], "visual"),
  new EdgeSelectorData("Translated as", Colors.green, "translated_as"),
  new EdgeSelectorData("Is in", Colors.grey[400], "in"),
  new EdgeSelectorData("Related to", Colors.grey[400], "related"),
  new EdgeSelectorData("Defenition", Colors.grey[400], "def"),
  new EdgeSelectorData("Defenition of", Colors.grey[400], "def_of"),
];

class TermDetailState extends State<TermDetail> {
  Widget cp = Container();
  Widget switcher = Container();
  String id;
  TermInfo term;
  int _addStatus = 1;

  TermDetailState(this.id);

  get appState {
    return appData.appState;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    var result = await fetchAudioList(id, 0, 10);
    setState(() {
      term = result;
      cp = getAudiosPage();
      switcher = Row(
        children: <Widget>[Text("1 "), Text("2")],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    });
  }

  void addContent() {
    if (_addStatus == 0) {
      setState(() {
        _addStatus = 1;
      });
    } else if (_addStatus == 1) {
      setState(() {
        _addStatus = 0;
      });
    }
  }

  void openAddAudio() {
    print("audio open!");
    var route = MaterialPageRoute(
        builder: (_) => new RecordAudioScreen(
              term: term,
            ));
    Navigator.pushReplacement(context, route);
  }

  Widget getAudiosPage() {
    return term.audio.items.length > 0
        ? new AudioList(term, fetchData)
        : Align(
            child: Container(
              width: 200,
              child: Text(
                "No audios yet ;)",
                style: TextStyle(fontSize: 20, color: Colors.blue[800]),
              ),
              alignment: Alignment(0, 0),
              padding: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: <BoxShadow>[BoxShadow(blurRadius: 5)]),
            ),
          );
  }

  var currentPage = 0.0;

  @override
  Widget build(BuildContext context) {
    if (term == null) {
      return Loading();
    }

    PageController controller = PageController(initialPage: 0);

    controller.addListener(() {
      setState(() {
        currentPage = controller.page;
      });
    });

    var RadialAddButton = Container(
        child: RadialMenu(
      icons: <RadialBtn>[
        RadialBtn(
            angle: 160,
            color: Colors.grey[600],
            icon: FontAwesomeIcons.cameraRetro,
            onTap: () {
              openCamera();
            }),
        RadialBtn(
            angle: 110,
            color: Colors.green,
            icon: FontAwesomeIcons.images,
            onTap: () {
              openGalery();
            }),
        RadialBtn(
            angle: 40,
            color: Colors.orange,
            icon: FontAwesomeIcons.microphoneAlt,
            onTap: () {
              openAddAudio();
            }),
      ],
    ));

    return new Scaffold(
      appBar: AppBar(
        title: Text("Detail"),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: TermView(term: term, tappable: false),
          ),
          //switcher,
          Stack(
            children: <Widget>[
              Positioned(child: HorizontalEdgeMenu(currentPage)),
              Positioned.fill(
                child: PageView.builder(
                  itemCount: title.length,
                  controller: controller,
                  reverse: false,
                  itemBuilder: (context, index) {
                    return Container(
                        //child: Text(index.toString()),
                        );
                  },
                ),
              )
            ],
          ),
          cp,

          RadialAddButton,
        ],
      ),
    );
  }

  void openCamera() async {
    File cameraFile;
    print("camera open!");
    cameraFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      //maxHeight: 50.0,
      //maxWidth: 50.0,
    );
    if (cameraFile != null) {
      print("You selected camera image : " + cameraFile.path);
      uploadPhoto(cameraFile);
    } else {
      print("no data");
    }
    setState(() {});
  }

  void openGalery() async {
    File galleryFile;

    galleryFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      // maxHeight: 50.0,
      // maxWidth: 50.0,
    );
    if (galleryFile != null) {
      print("You selected gallery image : " + galleryFile.path);
      uploadPhoto(galleryFile);
    } else {
      print("no data");
    }
    setState(() {});
  }

  void uploadPhoto(File f) async {
    List<int> bytes = f.readAsBytesSync();

    // TODO link to current term
    var uuid = new Uuid();
    final user = appData.appState.user;
    String datauid = uuid.v4();
    final remotePath = "user/${user.uid}/visual/${datauid}.jpeg";

    var res = await upload("$remotePath", 'visual/jpeg', bytes);
    TermUpdate tup = new TermUpdate();
    tup.imageUid = res.uid;
    print(tup.imageUid);
    var res2 = await upadteTerm(term.uid, tup);
    print(res2.toString());
  }
}

var gar = 12.0 / 16.0;

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
//Горизонтальное меню прокрутки
//Использует "хак", подсмотренный тут - https://www.youtube.com/watch?v=5KbiU-93-yU&t=1s
//создаётся PageView, который однако не рисуется, но из него берётся контроллер, который знает текущую страницу
//в виде double величины, то есть можно плавно скролить вбок
//В виджете элементы запихиваются в Stack, проходя циклом по всем менюшкам
//На основе "разницы" с текущей страницей высчитывается смещение каждого элемента
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                color: title[i].backColor,
                boxShadow: [
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
