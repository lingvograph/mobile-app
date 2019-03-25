import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:memoapp/components/appbar.dart';
import 'package:memoapp/components/loading.dart';
import 'package:memoapp/components/wordview.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/model.dart';
import 'package:memoapp/screen/contentmanagment.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/model.dart';
import 'package:memoapp/screen/userprofile.dart';
import 'package:memoapp/utils.dart';

const timeout = 5000;

var audioPlayer = new AudioPlayer();

// TODO cool transition between images

// main screen with word
class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<HomeScreen> {
  List<Word> words = new List();
  int total;
  ScrollController scrollController = new ScrollController();

  get appState {
    return appData.appState;
  }

  @override
  void initState() {
    super.initState();

    fetchPage();

    scrollController.addListener(() {
      var atBottom = scrollController.position.pixels ==
          scrollController.position.maxScrollExtent;
      if (atBottom && words.length < total) {
        fetchPage();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO goto login if appState has null user
    if (words.length == 0) {
      return Loading();
    }
    return MaterialApp(
      home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: buildAppBar(context),
            bottomNavigationBar: new TabBar(
              tabs: makeTabs(),
            ),
            body: TabBarView(
              children: makeTabViews(),
            ),
          )),
    );
  }

  /*create new method */
  fetchPage() async {
    var result = await appData.lingvo.fetch(words.length, 5);
    setState(() {
      total = result.total;
      words.addAll(result.items);
    });
  }

  void playSound(int index) {
    this.setState(() {
      var firstLang = appState.user?.firstLang ?? 'ru';
      var sound = firstByKey(words[index].pronunciation, firstLang, false);
      if (sound != null) {
        audioPlayer.play(sound.url);
      }
    });
  }

  List<Widget> makeTabs() {
    return [
      new Tab(
        icon: new Icon(
          Icons.home,
          color: Colors.black,
        ),
      ),
      new Tab(
        icon: new Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      new Tab(
        icon: new Icon(
          Icons.perm_identity,
          color: Colors.black,
        ),
      ),
    ].toList();
  }

  List<Widget> makeTabViews() {
    return [
      makeListView(),
      new ContentManager(),
      new UserProfile(),
    ].toList();
  }

  Widget makeListView() {
    return new ListView.builder(
        controller: scrollController,
        itemCount: words.length,
        itemBuilder: (BuildContext context, int index) {
          return new WordView(
            appState: appState,
            word: words[index],
          );
        });
  }
}
