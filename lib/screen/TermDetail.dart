import 'dart:io';

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

class TermDetailState extends State<TermDetail> {
  Widget currentPage = Container();
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
      currentPage = getAudiosPage();
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

  @override
  Widget build(BuildContext context) {
    if (term == null) {
      return Loading();
    }
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
          switcher,
          currentPage,

          YoutubePlayer(
            //isLive: true,
            hideShareButton: true,
            context: context,
            source: "JuQQM32k2mU&lc=z224t3wq2sbndbsdsacdp43bwaf2blv00dceh31rvmhw03c010c.1562517384972474",
            quality: YoutubeQuality.HD,
            // callbackController is (optional).
            // use it to control player on your own.

          ),
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
