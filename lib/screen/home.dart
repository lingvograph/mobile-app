import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/model.dart';
import 'package:memoapp/state.dart';
import 'package:memoapp/ui/loading.dart';

T firstByKey<T>(Map<String, T> text, String key, [bool eq = true]) {
  var entry = text.entries.firstWhere((e) => (e.key == key) == eq, orElse: null);
  if (entry == null) {
    return null;
  }
  return entry.value;
}

const timeout = Duration(seconds: 5);
const ms = const Duration(milliseconds: 1);

setTimeout(void callback(), [int milliseconds]) {
  var duration = milliseconds == null ? timeout : ms * milliseconds;
  return new Timer(duration, callback);
}

var audioPlayer = new AudioPlayer();

// TODO cool transition between images

// main screen with word
class HomeScreen extends StatefulWidget {
  final AppState appState;

  HomeScreen(this.appState);

  @override
  State<StatefulWidget> createState() => HomeState(appState);
}

class HomeState extends State<HomeScreen> {
  AppState appState;
  Word word;

  HomeState(this.appState) {
    nextWord();
  }

  @override
  Widget build(BuildContext context) {
    if (word == null) {
      return Loading();
    }
    return WordView(appState, word);
  }

  nextWord() async {
    var word = await appData.lingvo.nextWord();
    setState(() {
      this.word = word;
      playSound();
    });
    setTimeout(this.nextWord);
  }

  playSound() {
    var firstLang = this.appState.user.firstLang;
    var sound = firstByKey(word.pronunciation, firstLang, false);
    if (sound != null) {
      audioPlayer.play(sound.url);
    }
  }
}

class WordView extends StatelessWidget {
  final AppState appState;
  final Word word;

  WordView(this.appState, this.word);

  @override
  Widget build(BuildContext context) {
    var user = this.appState.user;
    var firstLang = user.firstLang;
    var text1 = firstByKey(word.text, firstLang, false);
    var text2 = firstByKey(word.text, firstLang, true);
    var trans = firstByKey(word.transcription, firstLang, true);
    return Scaffold(
      body: Center(
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
      ),
    );
  }
}
