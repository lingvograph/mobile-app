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
import 'package:memoapp/components/iconWithShadow.dart';
import 'package:memoapp/components/styles.dart';
import 'package:memoapp/screen/Discover.dart';
import 'package:memoapp/screen/TermDetail.dart';
import 'package:memoapp/screen/detailedImageScreen.dart';
import 'package:memoapp/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youtube_player/youtube_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'nonCachedImage.dart';

/*Ультимативный typedef*/
typedef SearchCallback = void Function(TermInfo termForSearch);

class TermView extends StatefulWidget {
  static String randomImageUrl = "https://picsum.photos/400/?blur";
  SearchCallback onSearch;

  TermView(
      {this.term,
      this.tappable = true,
      this.onSearch = null,
      this.viewMode = 1});

  _TermState createState() => _TermState();
  final TermInfo term;
  final bool tappable;

  //1 - full view
  //2 - semi-compact view
  //3 - compact view(only text)
  int viewMode;

  static loadImg(MediaInfo visual) {
    var url = visual.url;
    if (url.contains("unsplash.com") || url.contains("picsum")) {
      //print("spec "+url);
      ImageProvider img;

      img = NonCachedImage(
        url,
        visual.uid,
        useDiskCache: false,
        disableMemoryCache: false,
        retryLimit: 1,
        timeoutDuration: Duration(seconds: 30),
      );

      return img;
    } else {
      ImageProvider img;

      img = CachedNetworkImageProvider(url);
      return img;
    }
  }
}

class _TermState extends State<TermView> {
  int _current = 0;
  double tagsBarHeight = 0;
  double maxTagHeight = 30;
  double width;
  double imgH;
  Color textColor = Colors.blue[900];

  var trans = "";

  AppState get appState {
    return appData.appState;
  }

  TermInfo get term {
    return widget.term;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    trans = widget.term.transcript != null && widget.term.transcript.length > 0
        ? widget.term.transcript[0].text
        : "";
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    if (widget.viewMode == 1) {
      return makeFullTermView(context);
    }
    if (widget.viewMode == 2) {
      return makeSemiCompactTermView(context);
    }
    if (widget.viewMode == 3) {
      return makeCompactView(context);
    }
  }

  Widget getTags() {
    List<Widget> tags = new List();
    for (int i = 0; i < term.tags.length; i++) {
      tags.add(InkWell(
        child: Container(
          padding: EdgeInsets.all(1),
          child: Container(
            decoration: BoxDecoration(
                border: new Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(4)),
            child: Text(
              term.tags[i].text.length > 3
                  ? term.tags[i].text.substring(0, 3) + '.'
                  : term.tags[i].text,
              style: TextStyle(color: Colors.blueAccent, fontSize: 17),
            ),
            padding: EdgeInsets.all(2),
          ),
        ),
        onTap: () {
          tagtap(term.tags[i]);
        },
      ));
    }
    return Container(
      child: Row(
        children: tags,
      ),
    );
  }

  Widget makeCompactView(BuildContext context) {
    var firstLang = appState.user?.firstLang ?? 'ru';
    var text1 = term.text ?? '';
    var text2 = firstOrElse(
            term.translations
                .where((t) => t.lang == firstLang)
                .map((t) => t.text),
            '') ??
        '';
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[200],
                boxShadow: <BoxShadow>[
                  BoxShadow(color: Colors.grey[400], blurRadius: 4)
                ]),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    InkWell(
                      child: Text(text1,
                          style:
                              TextStyle(fontSize: 19, color: Colors.blue[600])),
                      onTap: () {
                        //print("kurwa");

                        pushTermRoute(term.uid);
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(2),
                    ),
                    Text("@" + term.lang,
                        style:
                            TextStyle(fontSize: 19, color: Colors.blue[800])),
                    Padding(
                      padding: EdgeInsets.all(1),
                    ),
                    text2.length > 0
                        ? Row(
                            children: <Widget>[
                              Text("Translation: ",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.blue[800])),
                              Text(text2,
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.blue[600]))
                            ],
                          )
                        : Container(),
                    Padding(
                      padding: EdgeInsets.all(2),
                    ),
                    Text(trans.length > 0 ? "[" + trans + "]" : "",
                        style:
                            TextStyle(fontSize: 18, color: Colors.blue[800])),
                    Padding(
                      padding: EdgeInsets.all(2),
                    ),
                    getTags(),
                    IconButton(
                      icon: Icon(
                        Icons.play_arrow,
                        color: term.audio.items.length > 0
                            ? Colors.blue[600]
                            : Colors.grey[600],
                      ),
                      onPressed: () {
                        playSound();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget makeSemiCompactTermView(BuildContext context) {
    var firstLang = appState.user?.firstLang ?? 'ru';

    var text1 = term.text ?? '';
    var text2 = firstOrElse(
            term.translations
                .where((t) => t.lang == firstLang)
                .map((t) => t.text),
            '') ??
        '';
    return Container(
      width: 200,
      height: 180,
      child: Column(children: <Widget>[
        Container(
            constraints: new BoxConstraints.expand(
              height: 180.0,
              width: 200,
            ),
            decoration: BoxDecoration(boxShadow: <BoxShadow>[
              BoxShadow(color: Colors.grey, blurRadius: 5)
            ]),
            child: Stack(
              // TODO improve position of subtitles
              children: <Widget>[
                new InkWell(
                    onTap: termOnTap,
                    child: makeImage(term.visual.items[0], context)),
                Positioned(
                  width: 180,
                  top: 25,
                  left: 10,
                  child: text1.length > 20
                      ? new Text(text1.substring(0, 20) + "...",
                          style: termTextStyle)
                      : Wrap(
                          children: <Widget>[
                            new Text(text1, style: termTextStyle)
                          ],
                        ),
                ),
              ],
            )),
      ]),
    );
  }

  Padding makeFullTermView(BuildContext context) {
    imgH = width / 2;
    maxTagHeight = 50 * term.tags.length.toDouble() / 3;
    var firstLang = appState.user?.firstLang ?? 'ru';
    //print(firstLang);
    var text1 = term.text ?? '';
    var text2 = firstOrElse(
            term.translations
                .where((t) => t.lang == firstLang)
                .map((t) => t.text),
            '') ??
        '';
    var slider = makeSlider(context);

    var dots = initDots();
    var termText1 = Positioned(
      left: 10,
      top: 10,
      child: Container(
        child: text1.length > 25
            ? new Text(text1.substring(0, 25) + "...", style: termTextStyle)
            : new Text(text1, style: termTextStyle),
        width: 300,
      ),
    );
    var termTranscript = Positioned(
      left: 10,
      top: 55,
      child: Row(
        children: <Widget>[
          new Text(text2, style: transcriptStyle),
          InkWell(
            onTap: () {
              if (widget.term.transcript != null &&
                  widget.term.transcript.length > 0) {
                pushTermRoute(term.transcript[0].uid);
              }
            },
            child: Text(trans.length > 0 ? (' [' + trans + ']') : '',
                style: transcriptStyle),
          ),
        ],
      ),
    );
    var iconPlayAudio = term.audio.total > 0
        ? Positioned(
            left: 10,
            top: 100,
            child: InkWell(
                onTap: () {
                  playSound();
                },
                child: IconWithShadow(
                  child: Icons.play_circle_outline,
                  size: 58,
                  color: Colors.grey[200],
                  left: 1,
                  top: 1,
                )),
          )
        : Container();
    var firstAudio = firstOrElse(term.audio.items, MediaInfo.empty);
    var views = Column(
      children: <Widget>[
        Container(
          width: 30,
          child: Icon(
            FontAwesomeIcons.eye,
            color: Colors.blueAccent,
            size: 20,
          ),
        ),
        Text(
          firstAudio.views.toString() + " views",
          style: TextStyle(color: textColor),
        )
      ],
    );
    var likes = Column(
      children: <Widget>[
        InkWell(
            child: Container(
              width: 30,
              child: Icon(
                FontAwesomeIcons.thumbsUp,
                color: Colors.blueAccent,
                size: 20,
              ),
            ),
            onTap: () {
              //debugPrint(firstAudio.uid);
              like(appState.user.uid, term.uid);
            }),
        Text(
          term.likes.toString() + " likes",
          style: TextStyle(color: textColor),
        )
      ],
    );
    var dislikes = Column(
      children: <Widget>[
        InkWell(
            child: Container(
              width: 30,
              child: Icon(
                FontAwesomeIcons.thumbsDown,
                color: Colors.blueAccent,
                size: 20,
              ),
            ),
            onTap: () {
              dislike(appState.user.uid, term.uid);
            }),
        Text(
          term.dislikes.toString() + " dislikes",
          style: TextStyle(color: textColor),
        )
      ],
    );

    var dotsIndicators = Container(
      alignment: Alignment(0, 1),
      child: Row(children: dots, mainAxisAlignment: MainAxisAlignment.center),
    );
    var tagsView = Container(
      alignment: Alignment(0, 0),
      child: Row(children: term.tags.map((t) => tagFromTerm(t)).toList()),

      ///duration: Duration(milliseconds: 300),
    );
    return Padding(
      padding: EdgeInsets.only(left: 5, right: 5, top: 10),
      child: Container(
        decoration: BoxDecoration(
            border: new Border.all(color: Colors.grey[500]),
            borderRadius: BorderRadius.circular(5)),
        child: Column(children: <Widget>[
          Container(
              constraints: new BoxConstraints.expand(
                height: 200.0,
              ),
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  //BoxShadow(color: Colors.grey[500], blurRadius: 5)
                ],
              ),
              child: Stack(
                // TODO improve position of subtitles
                children: <Widget>[
                  slider,
                  termText1,
                  termTranscript,
                  iconPlayAudio,
                  //termInfoField,
                  //showTagsIcon,
                  dotsIndicators
                ],
              )),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey[400],
                      offset: Offset(1, 1),
                      blurRadius: 5)
                ]),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(2),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(3),
                    ),
                    views,
                    Padding(
                      padding: EdgeInsets.all(3),
                    ),
                    likes,
                    Padding(
                      padding: EdgeInsets.all(3),
                    ),
                    dislikes
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(3),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(3),
                    ),
                    tagsView
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget tagFromTerm(TermInfo t) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: InkWell(
        child: Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
                border: new Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(4)),
            child: Text(
              "#" + (t.text ?? "") + " ",
              style: TextStyle(color: Colors.blue),
            )),
        onTap: () {
          //print(t.uid.toString());

          tagtap(t);
        },
      ),
    );
  }

  void tagtap(TermInfo t) {
    if (widget.onSearch == null) {
      List<TermInfo> tags = new List();
      tags.add(t);
      TermFilter tf = new TermFilter("", tags: tags);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DiscoverScreen(filter: tf)));
    } else {
      widget.onSearch(t);
    }
  }

  void expandTags() {
    setState(() {
      tagsBarHeight = tagsBarHeight != 0 ? 0 : maxTagHeight;
    });
  }

  void pushTermRoute(String uid) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TermDetail(
                  uid,
                )));
  }

  void termOnTap() {
    if (widget.tappable) {
      // TODO view visual, not audio
      if (term.audio.items.isNotEmpty) {
        view(appState.user.uid, term.audio.items[0].uid);
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TermDetail(
                    term.uid,
                  )));
    }
  }

  List<Widget> initDots() {
    var dots = new List<Widget>();
    if (term.visual.items.length > 1) {
      for (int i = 0; i < term.visual.items.length; i++) {
        double size = 8.0;
        if (i == term.visual.items.length - 1 || i == 0) {
          size = 5;
        }
        if (i == _current) {
          size = 8;
        }
        dots.add(Container(
          width: size,
          height: size,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == i
                  ? Color.fromRGBO(0, 0, 0, 0.9)
                  : Color.fromRGBO(0, 0, 0, 0.6)),
        ));
      }
    }
    return dots;
  }

  Widget makeSlider(BuildContext context) {
    var images = term.visual.items;
    if (images.isEmpty) {
      images = new List<MediaInfo>();
      final placeholderURL = 'https://picsum.photos/600';
      images.add(new MediaInfo(url: placeholderURL));
    }
    return images.length == 1
        ? makeImage(images.first, context)
        : CarouselSlider(
            height: imgH,
            viewportFraction: 1.0,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
            },
            items: images.map((t) => makeImage(t, context)).toList());
  }

  Widget makeImage(MediaInfo visual, BuildContext context) {
    //print(visual.url);

    var img = InkWell(
      child: new Container(
        padding: new EdgeInsets.only(left: 10.0, right: 10.0),
        decoration: new BoxDecoration(
          //borderRadius: BorderRadius.circular(10),
          //border: new Border.all(color: Colors.grey, width: 2),
          image: new DecorationImage(
            image: TermView.loadImg(visual),
            fit: BoxFit.cover,
          ),
        ),
        //child: loadImg(visual.url),
      ),
      onTap: () {
        if (!widget.tappable) {
          //print("kurwa");

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DetailedImage(visual)));
        } else {
          termOnTap();
        }
      },
    );
    if (visual.url == null) return img;
    return visual.url.toString().contains("www.youtube.com")
        ? Container(
            child: YoutubePlayer(
              hideShareButton: true,
              //isLive: true,
              context: context,
              source: visual.url,
              quality: YoutubeQuality.HIGH,
              // callbackController is (optional).
              // use it to control player on your own.
            ),
          )
        : img;
  }

  String getTubeVideoSource(String url) {
    //print(url);
    return url.replaceAll("https://www.youtube.com/watch?v=", "");
  }

  void playSound() {
    var audioPlayer = new AudioPlayer();
    var sound = firstOrElse(term.audio.items, null);
    if (sound != null) {
      audioPlayer.play(sound.url);
    }
  }
}
