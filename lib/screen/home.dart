import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/model.dart';
import 'package:memoapp/state.dart';
import 'package:memoapp/ui/loading.dart';

// main screen with word
class HomeScreen extends StatefulWidget {
  AppState appState;

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
    return WordView(word);
  }

  nextWord() async {
    var word = await appData.lingvo.nextWord();
    setState(() {
      this.word = word;
    });
  }
}

class WordView extends StatelessWidget {
  Word word;

  WordView(this.word);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CachedNetworkImage(
          placeholder: CircularProgressIndicator(),
          imageUrl: word.image.url,
        ),
      ),
    );
  }
}
