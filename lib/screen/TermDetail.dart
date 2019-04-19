import 'package:flutter/material.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/api.dart';
import 'package:memoapp/components/Loading.dart';
import 'package:memoapp/components/TermView.dart';
import 'package:memoapp/components/AudioList.dart';

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

  TermDetailState(this.id);

  get appState {
    return appData.appState;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async  {
    var result = await fetchAudioList(id, 0, 10);
    setState(() {
      term = result;
    });
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
            child: TermView(term, tappable: false),
          ),
          new AudioList(
            term: term,
          )
        ],
      ),
    );
  }
}
