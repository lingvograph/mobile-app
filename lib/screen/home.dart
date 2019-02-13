import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/model.dart';
import 'package:memoapp/appstate.dart';
import 'package:memoapp/components/appbar.dart';
import 'package:memoapp/components/loading.dart';
import 'package:memoapp/components/wordview.dart';
import 'package:memoapp/utils.dart';

const timeout = 5000;

var audioPlayer = new AudioPlayer();

// TODO cool transition between images

// main screen with word
class HomeScreen extends StatefulWidget {
  final AppState appState = appData.appState;

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
    // TODO goto login if appState has null user
    if (word == null) {
      return Loading();
    }
    return Scaffold(
      appBar: buildAppBar(context),
      body: WordView(appState, word),
    );
  }

  nextWord() async {
    var word = await appData.lingvo.nextWord();
    setState(() {
      this.word = word;
      playSound();
    });
    setTimeout(this.nextWord, timeout);
  }

  playSound() {
    var firstLang = this.appState.user?.firstLang ?? 'ru';
    var sound = firstByKey(word.pronunciation, firstLang, false);
    if (sound != null) {
      audioPlayer.play(sound.url);
    }
  }
}
