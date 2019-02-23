import 'package:flutter/material.dart';
import 'package:memoapp/model.dart';

/*Widget used to decorate input fields with rounded and fill it with grey color*/
class WordAudiosList extends StatefulWidget {
  Word word;

  //предполагаю из него будем вытаскивать озвучки по ID
  WordAudiosList({@required this.word});

  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<WordAudiosList> {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Column(
        children: <Widget>[
          Text(
            "dssdsd",
            style: TextStyle(fontSize: 30),
          ),
          //new LoadedAudiosList(),
        ],
      ),
    );
  }
}

class LoadedAudiosList extends StatefulWidget {
  @override
  _AudiosState createState() => _AudiosState();
}

class _AudiosState extends State<LoadedAudiosList> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Expanded(
        child: Container(
      constraints: BoxConstraints.expand(),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.blue[100], borderRadius: BorderRadius.circular(10)),
      child: new Text(
          "ACHIEVEMENTS",
          style: TextStyle(fontSize: 20, decoration: TextDecoration.overline),
        ),
      ),
    );
  }
}
