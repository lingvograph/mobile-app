import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/api/model.dart';
import 'package:memoapp/components/Loading.dart';
import 'package:memoapp/components/TermView.dart';
import 'package:memoapp/components/AudioList.dart';
import 'package:memoapp/components/addContentButton.dart';

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

  @override
  Widget build(BuildContext context) {
    if (term == null) {
      return Loading();
    }
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
          new AudioList(term, fetchData),
          Container(
              child: RadialMenu(
            icons: <RadialBtn>[
              RadialBtn(
                  angle: 140,
                  color: Colors.grey[600],
                  icon: FontAwesomeIcons.cameraRetro,
                  onTap: null),
              RadialBtn(
                  angle: 90,
                  color: Colors.green,
                  icon: FontAwesomeIcons.images,
                  onTap: null),
              RadialBtn(
                  angle: 40,
                  color: Colors.orange,
                  icon: FontAwesomeIcons.microphoneAlt,
                  onTap: null),
            ],
          )),
        ],
      ),
    );
  }
}
