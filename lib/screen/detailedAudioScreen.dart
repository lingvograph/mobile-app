import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/AppState.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/api/model.dart';
import 'package:memoapp/api/termquery.dart';
import 'package:memoapp/components/AudioList.dart';
import 'package:memoapp/components/TermView.dart';
import 'package:memoapp/components/iconWithShadow.dart';
import 'package:memoapp/components/styles.dart';
import 'package:memoapp/screen/Discover.dart';
import 'package:memoapp/screen/TermDetail.dart';
import 'package:memoapp/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youtube_player/youtube_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';


class DetailedAudioScreen extends StatefulWidget {
  MediaInfo audio;

  DetailedAudioScreen(this.audio) {}

  _DetailedState createState() => _DetailedState();
}

class _DetailedState extends State<DetailedAudioScreen> {
  List<TermView> terms;

  void getTerms() async {
    //List<TermInfo> termsData;
    TermFilter filter = new TermFilter('', audioUid: widget.audio.uid);
    var result =
    await appData.lingvo.fetchTerms(0, 5, filter: filter, lang: 'en');
    //print(result.items.length);

    for (int i = 0; i < result.total; i++) {
      try {
        setState(() {
          //print(result.items[i].text);
          terms.add(TermView(
            term: result.items[i],
          ));
        });
      } catch (e) {}
    }
  }

  @override
  void initState() {
    terms = new List();
    // TODO: implement initState
    super.initState();
    getTerms();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("Detail Audio"),
        ),
        body: Container(
            padding: EdgeInsets.all(5),
            child: ListView(
              children: <Widget>[
                Container(
                  child: LoadedAudio(widget.audio,null, 'en'),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "made by ",
                      style: TextStyle(fontSize: 17),
                    ),
                    Container(
                        padding: EdgeInsets.all(2),
                        child: Text(
                          widget.audio.author != null
                              ? widget.audio.author.name
                              : 'generated',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                        decoration: BoxDecoration(
                            border: new Border.all(
                                color: Colors.blueAccent, width: 2),
                            borderRadius: BorderRadius.circular(5)))
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text("source ", style: TextStyle(fontSize: 17)),
                    Container(
                        padding: EdgeInsets.all(2),
                        child: Text(
                          widget.audio.source != null &&
                              widget.audio.source.length > 0
                              ? widget.audio.source
                              : widget.audio.url.substring(
                              0, widget.audio.url.indexOf("/", 8)),
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                        decoration: BoxDecoration(
                            border: new Border.all(
                                color: Colors.blueAccent, width: 2),
                            borderRadius: BorderRadius.circular(5)))
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                Center(child: Text(terms.length>0?"Terms using this audio ":"", style: TextStyle(fontSize: 18,color: Colors.blue[800])),),
                Column(
                  children: terms,
                )
              ],
            )));
  }
}
