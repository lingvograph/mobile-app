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
  List<Word> words;
  int wordsLoaded;
  HomeState(this.appState) {
    //nextWord();
    wordsLoaded = 0;
    words = new List();
    for(int i=0;i<4; i++)
      {
        loadNextWord();
      }
  }

  @override
  Widget build(BuildContext context) {
    // TODO goto login if appState has null user
    if (wordsLoaded == 0) {
      return Loading();
    }
    return Scaffold(
      appBar: buildAppBar(context),
      body: /*WordView(appState, word)*/
      ListView.builder(itemCount: wordsLoaded,
          itemBuilder: (BuildContext context, int index)
          {
            /*Loading new element after just reaching end of list, infinit scroll effect
            * Also need to clear previous items of list(have no idea how to do it)
            * May it will be OK to stop loading after reaching the last possible item,
            * but the is no method to check elements count now*/
            if(index == wordsLoaded-1)
              {
                loadNextWord();
              }
            return new WordView(appState, words[index]);
          }
      )
    );
  }
  /*create new method */
  loadNextWord() async {
    var word = await appData.lingvo.nextWord();
    setState(() {
      words.add(word);
      wordsLoaded++;
    });
    //setTimeout(this.nextWord, timeout);
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
      //audioPlayer.play(sound.url);
    }
  }
}
