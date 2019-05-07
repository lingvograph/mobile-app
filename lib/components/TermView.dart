import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/AppState.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/api/model.dart';
import 'package:memoapp/components/iconWithShadow.dart';
import 'package:memoapp/components/styles.dart';
import 'package:memoapp/screen/TermDetail.dart';
import 'package:memoapp/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';

/*Ультимативный typedef*/
typedef SearchCallback = void Function(String searchString);

class TermView extends StatefulWidget {
  SearchCallback onSearch;

  TermView({this.term, this.tappable = true, this.onSearch = null});

  _TermState createState() => _TermState();
  final TermInfo term;
  final bool tappable;
}

class _TermState extends State<TermView> {
  int _current = 0;
  double tagsBarHeight = 0;
  double maxTagHeight = 30;

  AppState get appState {
    return appData.appState;
  }

  TermInfo get term {
    return widget.term;
  }

  @override
  Widget build(BuildContext context) {
    maxTagHeight = 50*term.tags.length.toDouble()/3;
    var firstLang = appState.user?.firstLang ?? 'ru';
    var text1 = term.text ?? '';
    var text2 = firstOrElse(
            term.translations
                .where((t) => t.lang == firstLang)
                .map((t) => t.text),
            '') ??
        '';
    var trans = firstByKey(term.transcript, firstLang, true) ?? '';
    var slider = makeSlider();

    var dots = initDots();
    var termText1 = Positioned(
      left: 10,
      top: 10,
      child: Container(
        child: new Text(text1, style: termTextStyle),
        width: 300,
      ),
    );
    var termTranscript = Positioned(
      left: 10,
      top: 50,
      child: trans.isEmpty
          ? Text("")
          : new Text(text2 + ' [' + trans + ']', style: transcriptStyle),
    );
    var iconPlayAudio = Positioned(
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
    );
    var firstAudio = firstOrElse(term.audio.items, MediaInfo.empty);
    var termInfo = Row(
      children: <Widget>[
        IconWithShadow(
            color: Colors.grey[200],
            child: Icons.remove_red_eye,
            left: 1,
            top: 1),
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
                child: Icons.thumb_up,
                left: 1,
                top: 1),
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
                child: Icons.thumb_down,
                left: 1,
                top: 1),
            onTap: () {
              dislike(appState.user.uid, firstAudio.uid);
            }),
        Text(
          firstAudio.dislikes.toString(),
          style: termTextStyleInfo,
        ),
      ],
    );
    var termInfoField = Positioned(
        left: 200, top: 150, child: widget.tappable ? termInfo : Text(""));
    var showTagsIcon = Positioned(
      top: 160,
      left: 10,
      child: InkWell(
        child: IconWithShadow(
          child: Icons.more_horiz,
          top: 1,
          left: 1,
          size: 50,
          color: Colors.blue,
        ),
        onTap: expandTags,
      ),
    );
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
          borderRadius: BorderRadius.circular(10),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black54, offset: Offset(1, 1), blurRadius: 5)
          ]),
    );
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
      child: Column(children: <Widget>[
        Container(
            constraints: new BoxConstraints.expand(
              height: 200.0,
            ),
            decoration: BoxDecoration(boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey, blurRadius: 5)]),
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
      child: Container(
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.grey[200],
          boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey[400],blurRadius: 2)]),
          child: Text(
            "#" + (t.text ?? "") + " ",
            style: TextStyle(color: Colors.blue),
          )),
    );
  }

  void expandTags() {
    setState(() {
      tagsBarHeight = tagsBarHeight == maxTagHeight ? 0 : maxTagHeight;
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

  Widget makeSlider() {
    var images = term.visual.items;
    if (images.isEmpty) {
      images = new List<MediaInfo>();
      final placeholderURL =
          'https://imgplaceholder.com/420x320/ff7f7f/333333/fa-image';
      images.add(new MediaInfo(url: placeholderURL));
    }
    return images.length == 1
        ? makeImage(images.first)
        : CarouselSlider(
            //height: 500.0,
            viewportFraction: 1.0,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            // good param to play with
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
            },
            items: images.map((t) => makeImage(t)).toList());
  }

  Widget makeImage(MediaInfo visual) {
    return new Container(
      padding: new EdgeInsets.only(left: 16.0, bottom: 8.0, right: 16.0),
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: new Border.all(color: Colors.grey, width: 2),
        image: new DecorationImage(
          image: new CachedNetworkImageProvider(visual.url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void playSound() {
    var audioPlayer = new AudioPlayer();
    var sound = firstOrElse(term.audio.items, null);
    if (sound != null) {
      audioPlayer.play(sound.url);
    }
  }
}
