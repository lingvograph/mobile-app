import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/model.dart';
import 'package:memoapp/state.dart';
import 'package:memoapp/ui/loading.dart';

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
    });
  }
}

class WordView extends StatelessWidget {
  final AppState appState;
  final Word word;

  WordView(this.appState, this.word);

  @override
  Widget build(BuildContext context) {
//    var image = CachedNetworkImage(
//      placeholder: CircularProgressIndicator(),
//      imageUrl: word.image.url,
//    );
    var screenSize = MediaQuery.of(context).size;
    var user = this.appState.user;
    var firstLang = user.firstLang;
    var text1 = word.text.entries.firstWhere((e) => e.key != firstLang).value;
    var text2 = word.text.entries.firstWhere((e) => e.key == firstLang).value;
    var transcription = word.transcription.entries.firstWhere((e) => e.key == firstLang).value;
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
                  child: new Text(text2 + ' [' + transcription + ']',
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
