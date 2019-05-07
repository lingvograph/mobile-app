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
    var route = MaterialPageRoute(builder: (_) => new RecordAudioScreen());
    Navigator.pushReplacement(context, route);
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
            padding: EdgeInsets.only(top: 10),
            child: TermView(term: term, tappable: false),
          ),
          term.audio.items.length > 0
              ? new AudioList(term, fetchData)
              : SizedBox(
                  height: 10,
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
    if (cameraFile!= null) {
      print("You selected camera image : " + cameraFile.path);
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
    if(galleryFile!=null)
      {
        print("You selected gallery image : " + galleryFile.path);
        List<int> bytes = galleryFile.readAsBytesSync();

        // TODO link to current term
        var uuid = new Uuid();
        final user = appData.appState.user;
        final remotePath = "user/${user.uid}/visual/${uuid.v4()}.jpeg";

        var res = await upload("$remotePath", 'visual/jpeg', bytes);
        print(res.path);
      }
    else
      {
        print("no data");
      }
    setState(() {});
  }
}
