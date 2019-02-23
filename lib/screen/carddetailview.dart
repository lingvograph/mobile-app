import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memoapp/components/cardtextstyle.dart';
import 'package:memoapp/model.dart';
import 'package:memoapp/appstate.dart';
import 'package:memoapp/utils.dart';
import 'package:memoapp/wordaudioslist.dart';

class DetailedWordView extends StatelessWidget {
  final AppState appState;
  final Word word;

  DetailedWordView({this.appState, this.word});

  @override
  Widget build(BuildContext context) {
    var firstLang = this.appState.user?.firstLang ?? 'ru';
    var text1 = firstByKey(word.text, firstLang, false);
    var text2 = firstByKey(word.text, firstLang, true);
    var trans = firstByKey(word.transcription, firstLang, true);

    return new Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: ListView(
        children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10, left: 15, right: 15),
              child: Container(
                  constraints: new BoxConstraints.expand(
                    height: 200.0,
                  ),
                  child: Stack(
                    // TODO improve position of subtitles
                    children: <Widget>[
                      new InkWell(
                        child: new Container(
                          padding: new EdgeInsets.only(
                              left: 16.0, bottom: 8.0, right: 16.0),
                          decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border:
                                new Border.all(color: Colors.grey, width: 2),
                            image: new DecorationImage(
                              image: new CachedNetworkImageProvider(
                                  word.image.url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: new Text(text1, style: WordTextStyle),
                      ),
                      Positioned(
                        left: 10,
                        top: 50,
                        child: new Text(text2 + ' [' + trans + ']',
                            style: TranscriptionTextStyle),
                      ),
                    ],
                  )),
            ),
            new WordAudiosList(word: word,),


        ],
      ),
    );
  }
}
