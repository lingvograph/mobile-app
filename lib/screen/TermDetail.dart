import 'package:flutter/material.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/api/model.dart';
import 'package:memoapp/components/Loading.dart';
import 'package:memoapp/components/TermView.dart';
import 'package:memoapp/components/AudioList.dart';

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
            decoration: new BoxDecoration(
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.blue, blurRadius: 3),
              ],
              shape: BoxShape.circle,
            ),
            child: Container(
              alignment: Alignment(-0.05, 0),
              padding: EdgeInsets.only(bottom: 15),
              //padding: EdgeInsets.only(bottom: 15, left: 150),
              child: AnimatedCrossFade(
                  alignment: Alignment(0, 0),
                  firstChild: new IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.blue,
                        size: 50,
                      ),
                      onPressed: addContent),
                  secondChild: new IconButton(
                      icon: Icon(
                        Icons.remove,
                        color: Colors.red,
                        size: 50,
                      ),
                      onPressed: addContent),
                  crossFadeState: _addStatus == 0
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: Duration(milliseconds: 300)),
            ),
          ),
          Padding(

            padding: EdgeInsets.all(20),
            child: AnimatedContainer(
              height: 100,
              transform: Matrix4.rotationY(_addStatus==1?0:3.14),
              alignment: FractionalOffset.centerRight,
              duration: Duration(milliseconds: 1000),
              child: Text("sdAA"),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20), boxShadow: <BoxShadow>[BoxShadow(color: Colors.black, blurRadius: 4)]),
            ),
          ),
        ],
      ),
    );
  }
}
