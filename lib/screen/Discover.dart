import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:memoapp/api.dart';
import 'package:memoapp/components/AppBar.dart';
import 'package:memoapp/components/Loading.dart';
import 'package:memoapp/components/RecordAudioWidget.dart';
import 'package:memoapp/components/TermView.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/screen/ContentManager.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/screen/UserProfile.dart';
import 'package:memoapp/utils.dart';

const timeout = 5000;

var audioPlayer = new AudioPlayer();

// TODO cool transition between images

// main screen with terms
class DiscoverScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DiscoverState();
}

class DiscoverState extends State<DiscoverScreen> {
  List<TermInfo> terms = new List();
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
      if (atBottom && terms.length < total) {
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
    if (terms.length == 0) {
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
    var result = await appData.lingvo.fetch(terms.length, 5);
    //print(result.toString());
    setState(() {
      total = result.total;
      terms.addAll(result.items);
    });
  }

  void playSound(int index) {
    var term = terms[index];
    if (term.audio.items.isEmpty) {
      return;
    }

    this.setState(() {
      var sound = term.audio.items.first;
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

  /*Ладно, на русском коментирую
  * Тут подключаю виджет(на самом деле экран) записи аудио*/
  List<Widget> makeTabViews() {
    return [
      makeListView(),
      RecordAudioWidget(),
      new UserProfile(),
    ].toList();
  }

  Widget makeListView() {
    return new ListView.builder(
        controller: scrollController,
        itemCount: terms.length,
        itemBuilder: (BuildContext context, int index) {
          return new TermView(terms[index]);
        });
  }
}

