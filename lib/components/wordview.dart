import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memoapp/model.dart';
import 'package:memoapp/state.dart';
import 'package:memoapp/utils.dart';

class WordView extends StatelessWidget {
  final AppState appState;
  final Word word;

  WordView(this.appState, this.word);

  @override
  Widget build(BuildContext context) {
    var firstLang = this.appState.user?.firstLang ?? 'ru';
    var text1 = firstByKey(word.text, firstLang, false);
    var text2 = firstByKey(word.text, firstLang, true);
    var trans = firstByKey(word.transcription, firstLang, true);
    return Center(
      child: Container(
          constraints: new BoxConstraints.expand(
            height: 200.0,
          ),
          padding: new EdgeInsets.only(left: 16.0, bottom: 8.0, right: 16.0),
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new CachedNetworkImageProvider(word.image.url),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            // TODO improve position of subtitles
            children: <Widget>[
              Positioned(
                left: 0,
                top: 10,
                child: new Text(text1,
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40.0,
                      color: Colors.white,
                    )),
              ),
              Positioned(
                left: 0,
                top: 50,
                child: new Text(text2 + ' [' + trans + ']',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white,
                    )),
              ),
            ],
          )),
    );
  }
}
