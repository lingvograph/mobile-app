import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/AppState.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/api/model.dart';
import 'package:memoapp/components/iconWithShadow.dart';
import 'package:memoapp/components/styles.dart';
import 'package:memoapp/screen/TermDetail.dart';
import 'package:memoapp/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youtube_player/youtube_player.dart';

/*Ультимативный typedef*/
typedef SearchCallback = void Function(TermInfo termForSearch);

class TermView extends StatefulWidget {
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
}

class _TermState extends State<TermView> {
  int _current = 0;
  double tagsBarHeight = 0;
  double maxTagHeight = 30;
  double width;
  double imgH;

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

  Widget makeCompactView(BuildContext context) {
    var firstLang = appState.user?.firstLang ?? 'ru';
    var text1 = term.text ?? '';
    var text2 = firstOrElse(
            term.translations
                .where((t) => t.lang == firstLang)
                .map((t) => t.text),
            '') ??
        '';
    var trans = firstByKey(term.transcript, firstLang, true) ?? '';
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
                    Text(text1,
                        style:
                            TextStyle(fontSize: 19, color: Colors.blue[600])),
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
                    Text("[" + trans + "]",
                        style:
                            TextStyle(fontSize: 18, color: Colors.blue[800])),
                    Padding(
                      padding: EdgeInsets.all(2),
                    ),
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
                    )
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
    var trans = firstByKey(term.transcript, firstLang, true) ?? '';
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
                    onTap: imageOnTap,
                    child: makeImage(term.visual.items[0], context)),
                Positioned(
                  top: 30,
                  left: 12,
                  child: text1.length > 15
                      ? new Text(text1.substring(0, 15) + "...",
                          style: termTextStyle)
                      : new Text(text1, style: termTextStyle),
                )
              ],
            )),
      ]),
    );
  }

  Padding makeFullTermView(BuildContext context) {
    imgH = width / 2;
    maxTagHeight = 50 * term.tags.length.toDouble() / 3;
    var firstLang = appState.user?.firstLang ?? 'ru';
    var text1 = term.text ?? '';
    var text2 = firstOrElse(
            term.translations
                .where((t) => t.lang == firstLang)
                .map((t) => t.text),
            '') ??
        '';
    var trans = firstByKey(term.transcript, firstLang, true) ?? '';
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
      child: trans.isEmpty
          ? Text("")
          : new Text(text2 + ' [' + trans + ']', style: transcriptStyle),
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
    var termInfo = term.audio.total > 0
        ? Row(
            children: <Widget>[
              Container(
                width: 30,
                child: IconWithShadow(
                    color: Colors.grey[200],
                    child: FontAwesomeIcons.eye,
                    left: 1.5,
                    top: 1.5),
              ),
              Padding(
                padding: EdgeInsets.all(2),
              ),
              Text(
                firstAudio.views.toString(),
                style: termTextStyleInfo,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
              ),
              InkWell(
                  child: IconWithShadow(
                      color: Colors.grey[200],
                      child: FontAwesomeIcons.thumbsUp,
                      left: 1.5,
                      top: 1.5),
                  onTap: () {
                    debugPrint(firstAudio.uid);
                    like(appState.user.uid, firstAudio.uid);
                  }),
              Text(
                firstAudio.likes.toString(),
                style: termTextStyleInfo,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
              ),
              InkWell(
                  child: IconWithShadow(
                      color: Colors.grey[200],
                      child: FontAwesomeIcons.thumbsDown,
                      left: 1.5,
                      top: 1.5),
                  onTap: () {
                    dislike(appState.user.uid, firstAudio.uid);
                  }),
              Text(
                firstAudio.dislikes.toString(),
                style: termTextStyleInfo,
              ),
            ],
          )
        : Container();
    var termInfoField = Positioned(
        left: 200, top: 150, child: widget.tappable ? termInfo : Text(""));
    var showTagsIcon = term.tags.length > 0
        ? Positioned(
            top: 160,
            left: 10,
            child: InkWell(
              child: IconWithShadow(
                child: Icons.more_horiz,
                top: 1,
                left: 1,
                size: 50,
                color: Colors.grey[200],
              ),
              onTap: expandTags,
            ),
          )
        : Container();
    var dotsIndicators = Container(
      alignment: Alignment(0, 1),
      child: Row(children: dots, mainAxisAlignment: MainAxisAlignment.center),
    );
    var tagsView = AnimatedContainer(
      alignment: Alignment(0, 0),
      child: Wrap(children: term.tags.map((t) => tagFromTerm(t)).toList()),
      duration: Duration(milliseconds: 300),
      height: tagsBarHeight,
      width: 200,
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(5),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black54, offset: Offset(1, 1), blurRadius: 5)
          ]),
    );
    return Padding(
      padding: EdgeInsets.only(left: 5, right: 5, top: 10),
      child: Column(children: <Widget>[
        Container(
            constraints: new BoxConstraints.expand(
              height: 200.0,
            ),
            decoration: BoxDecoration(boxShadow: <BoxShadow>[
              BoxShadow(color: Colors.grey[500], blurRadius: 5)
            ]),
            child: Stack(
              // TODO improve position of subtitles
              children: <Widget>[
                new InkWell(onTap: imageOnTap, child: slider),
                termText1,
                termTranscript,
                iconPlayAudio,
                termInfoField,
                showTagsIcon,
                dotsIndicators
              ],
            )),
        tagsView
      ]),
    );
  }

  Widget tagFromTerm(TermInfo t) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: InkWell(
        child: Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[200],
                boxShadow: <BoxShadow>[
                  BoxShadow(color: Colors.grey[400], blurRadius: 2)
                ]),
            child: Text(
              "#" + (t.text ?? "") + " ",
              style: TextStyle(color: Colors.blue),
            )),
        onTap: () {
          print(t.uid.toString());
          widget.onSearch(t);
        },
      ),
    );
  }

  void expandTags() {
    setState(() {
      tagsBarHeight = tagsBarHeight != 0 ? 0 : maxTagHeight;
    });
  }

  void imageOnTap() {
    if (widget.tappable) {
      // TODO view visual, not audio
      if (term.audio.items.isNotEmpty) {
        view(appState.user.uid, term.audio.items[0].uid);
      }
      var route = MaterialPageRoute(builder: (_) => new TermDetail(term.uid));
      Navigator.push(context, route);
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
      final placeholderURL =
          'https://i1.wp.com/thefrontline.org.uk/wp-content/uploads/2018/10/placeholder.jpg';
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

  loadImg(String url) {
    var img;
    img = new CachedNetworkImageProvider(url, errorListener: () {
      print("failed");
      img = CachedNetworkImageProvider(
          "https://i1.wp.com/thefrontline.org.uk/wp-content/uploads/2018/10/placeholder.jpg");
    });
    return img;
  }

  Widget makeImage(MediaInfo visual, BuildContext context) {
    print(visual.url);
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
        : new Container(
            padding: new EdgeInsets.only(left: 16.0, right: 16.0),
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: new Border.all(color: Colors.grey, width: 2),
              image: new DecorationImage(
                image: loadImg(visual.url),
                fit: BoxFit.cover,
              ),
            ),
          );
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
