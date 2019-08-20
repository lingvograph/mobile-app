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
import 'package:memoapp/components/TermView.dart';
import 'package:memoapp/components/iconWithShadow.dart';
import 'package:memoapp/components/styles.dart';
import 'package:memoapp/screen/Discover.dart';
import 'package:memoapp/screen/TermDetail.dart';
import 'package:memoapp/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youtube_player/youtube_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/*Ультимативный typedef*/

typedef SearchCallback = void Function(TermInfo termForSearch);

class DetailedImage extends StatefulWidget {
  MediaInfo image;

  DetailedImage(this.image) {}

  _DetailedState createState() => _DetailedState();
}

class _DetailedState extends State<DetailedImage> {
  List<TermView> terms;

  void getTerms() async {
    //List<TermInfo> termsData;
    TermFilter filter = new TermFilter('', visualUid: widget.image.uid);
    var result =
        await appData.lingvo.fetchTerms(0, 5, filter: filter, lang: 'en');
    print(result.items.length);

    for (int i = 0; i < result.total; i++) {
      try {
        setState(() {
          print(result.items[i].text);
          terms.add(TermView(term: result.items[i],));
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
          title: Text("Detail Visual"),
        ),
        body: Container(
            padding: EdgeInsets.all(5),
            child: ListView(
              children: <Widget>[
                Container(
                  child: Container(
                    height: 200,
                    //padding: new EdgeInsets.only(left: 3.0, right: 3.0),
                    decoration: new BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(blurRadius: 2, color: Colors.grey[500])
                      ],
                      borderRadius: BorderRadius.circular(5),
                      border: new Border.all(color: Colors.grey[400], width: 2),
                      image: new DecorationImage(
                        image: TermView.loadImg(widget.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  //padding: EdgeInsets.all(7),
                ),
                Padding(
                  padding: EdgeInsets.all(3),
                ),
                Row(
                  children: <Widget>[
                    Text("made by "),
                    Container(
                        padding: EdgeInsets.all(2),
                        child: Text(
                          widget.image.author != null
                              ? widget.image.author.name
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
                    Text("source "),
                    Container(
                        padding: EdgeInsets.all(2),
                        child: Text(
                          widget.image.source != null &&
                                  widget.image.source.length > 0
                              ? widget.image.source
                              : widget.image.url.substring(
                                  0, widget.image.url.indexOf("/", 8)),
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                        decoration: BoxDecoration(
                            border: new Border.all(
                                color: Colors.blueAccent, width: 2),
                            borderRadius: BorderRadius.circular(5)))
                  ],
                ),
                Column(children: terms,)
              ],
            )));
  }
}
