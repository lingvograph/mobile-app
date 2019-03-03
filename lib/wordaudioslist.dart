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
  List<Widget> audios;
  List<Widget> usageExamples;

  double width;
  @override
  Widget build(BuildContext context) {
    audios = new List();
    audios.add(new LoadedAudio());
    audios.add(new LoadedAudio());
    audios.add(new LoadedAudio());
    audios.add(new LoadedAudio());
    width = MediaQuery.of(context).size.width / 4;
    return new Center(
      child: Padding(
        padding: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
        child: Container(
          padding: EdgeInsets.only(top: 10),
          constraints: BoxConstraints.expand(
              height: ((audios.length.toDouble() + 1) * 60)),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
          child: new Column(
            children: <Widget>[
              new Column(
                children: audios,
              ),
              Padding(
                  padding: EdgeInsets.only(top: 4, left: width, right: width),
                  child: Container(
                      //padding: EdgeInsets.only(left: width),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new IconButton(
                              icon: Icon(
                                Icons.navigate_before,
                                size: 25,
                              ),
                              onPressed: null),
                          new IconButton(
                              icon: Icon(
                                Icons.navigate_next,
                                size: 25,
                              ),
                              onPressed: null),
                        ],
                      ))),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadedAudio extends StatefulWidget {
  @override
  _AudioState createState() => _AudioState();
}

class _AudioState extends State<LoadedAudio> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.only(top: 4, left: 20, right: 20),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: <Widget>[
                Text("Audio track N_"),
                Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: new IconButton(
                      icon: Icon(
                        Icons.play_arrow,
                        size: 25,
                      ),
                      onPressed: null),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                  ),
                  child: new IconButton(
                      icon: Icon(
                        Icons.details,
                        size: 25,
                      ),
                      onPressed: null),
                ),
              ],
            ),
          )),
    );
  }
}
