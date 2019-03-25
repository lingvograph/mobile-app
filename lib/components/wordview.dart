import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memoapp/components/cardtextstyle.dart';
import 'package:memoapp/model.dart';
import 'package:memoapp/appstate.dart';
import 'package:memoapp/screen/carddetailview.dart';
import 'package:memoapp/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';

class WordView extends StatelessWidget {
  final AppState appState;
  final Word word;

  WordView({this.appState, this.word});

  @override
  Widget build(BuildContext context) {
    var firstLang = this.appState.user?.firstLang ?? 'ru';
    var text1 = firstByKey(word.text, firstLang, false) ?? '';
    var text2 = firstByKey(word.text, firstLang, true) ?? '';
    var trans = firstByKey(word.transcription, firstLang, true) ?? '';
    int _current = 0;
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
      child: Container(
          constraints: new BoxConstraints.expand(
            height: 200.0,
          ),
          child: Stack(
            // TODO improve position of subtitles
            children: <Widget>[
              new InkWell(
                  onTap: () {
                    openThisCard(context, appState, word);
                  },
                  child: CarouselSlider(
                      //height: 500.0,
                      enlargeCenterPage: true,

                      items: <Widget>[
                        new Container(
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
                      ])),

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
              Positioned(
                left: 10,
                top: 100,
                child: InkWell(
                    onTap: () {
                      playSound();
                    },
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                            left: 3,
                            top: 1,
                            child: Icon(
                              Icons.play_circle_outline,
                              color: Colors.black,
                              size: 58,
                            )),
                        Positioned(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 60,
                          ),
                        )
                      ],
                    )),
              ),
            ],
          )),
    );
  }

  void playSound() {
    var audioPlayer = new AudioPlayer();
    var firstLang = this.appState.user?.firstLang ?? 'ru';
    var sound = firstByKey(word.pronunciation, firstLang, false);
    if (sound != null) {
      audioPlayer.play(sound.url);
    }
  }

  void openThisCard(BuildContext ctxt, AppState state, Word word) {
    Navigator.push(
        ctxt,
        MaterialPageRoute(
            builder: (context) => new DetailedWordView(
                  appState: state,
                  word: word,
                )));
  }
}
