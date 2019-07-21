import 'dart:convert';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/api/termquery.dart';
import 'package:memoapp/api/model.dart';
import 'package:memoapp/components/AppBar.dart';
import 'package:memoapp/components/Loading.dart';
import 'package:memoapp/components/RecordAudioWidget.dart';
import 'package:memoapp/components/TermView.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/screen/UserProfile.dart';

var notFound = {
  'uid': '0x277a',
  'text': '',
  'lang': 'en',
  'transcript@en': 'nf',
  'visual': [
    {
      'url':
          'https://webhostingmedia.net/wp-content/uploads/2018/01/http-error-404-not-found.png'
    }
  ]
};
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
  String searchString = '';

  get appState {
    return appData.appState;
  }

  @override
  void initState() {
    super.initState();

    fetchPage();
    tags = new List();

    getTagList();
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
            appBar: buildAppBar(context, doSearch),
            bottomNavigationBar: new TabBar(
              tabs: makeTabs(),
            ),
            body: TabBarView(
              children: makeTabViews(),
            ),
          )),
    );
  }
  List<TermInfo> tags;

  getTagList() async {
    var result = await getData("/api/data/tag/list");
    var terms = result['items'] as List<dynamic>;
    var items = terms.map((t) => tagTextFromJson(t)).toList();
    setState(() {
      tags = items;
    });
    //print(tags.toString());
  }

  TermInfo tagTextFromJson(t) {
    return TermInfo.fromJson(t);
  }

  List<TermInfo> getSelected(String text) {
    List<TermInfo> res = new List();
    for (int i = 0; i < tags.length; i++) {

      print(tags[i].text==null?"null":tags[i].text);
      //print(text+" "+text.replaceAll('#', ''));
      if (tags[i]!=null && tags[i].text!=null && text.length > 1 && tags[i].text.contains(text.substring(1))) {
        print(tags[i].text);

        res.add(tags[i]);
      }
    }
    return res;
  }
  doSearch(String text) async {
    if (text.length>0 && text[0]=="#") {
      print("by tag!");
      List<TermInfo> res = getSelected(text);
      if (res.length > 0) {
        total = res.length;

        terms = new List();
        for (int i = 0; i < res.length; i++) {
          try {
            setState(() {
              terms.add(res[i]);
            });
          } catch (e) {}
        }
      } else if (res.length == 0) {
        TermInfo t = TermInfo.fromJson(notFound);

        setState(() {
          terms = new List();
          terms.add(t);
          total = 1;
        });
      }

    } else {
      terms = new List();
      loadBySearch(text);
    }
  }

  loadBySearch(String t) async {
    if(t.length==0)
      {
        fetchPage();
      }
    else
    {
      var filter = new TermFilter(t);
      var result = await appData.lingvo.fetchTerms(0, 5, filter: filter);
      print(result.items.toList().toString());
      if (result.total > 0)
      {
        total = result.total;

        terms = new List();
        for (int i = 0; i < result.total; i++)
        {
          try
          {
            setState(()
            {
              terms.add(result.items[i]);
            });
          } catch (e)
          {}
        }
      } else if (result.total == 0)
      {
        TermInfo t = TermInfo.fromJson(notFound);

        setState(()
        {
          terms = new List();
          terms.add(t);
          total = 1;
        });
      }
    }
    //total = 2;
  }

  /*create new method */
  fetchPage() async {
    var filter = new TermFilter("");
    var result =
        await appData.lingvo.fetchTerms(terms.length, 5, filter: filter);

    //print(result.toString());
    setState(() {
      total = result.total;
      terms.addAll(result.items);
      print(total.toString());
      if (total == 0) {
        searchString = "";
        terms.clear();
        fetchPage();
        //terms.add(new TermInfo(text: "Nothing found", uid: "0x0"));
      }
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
          return new TermView(
            term: terms[index],
          );
        });
  }
}
