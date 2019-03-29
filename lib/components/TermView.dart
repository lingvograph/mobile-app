import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/api.dart';
import 'package:memoapp/components/styles.dart';
import 'package:memoapp/screen/TermDetail.dart';
import 'package:memoapp/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';

class TermView extends StatefulWidget {
  TermView(this.term, {this.tappable = true});

  _TermState createState() => _TermState();
  final TermInfo term;
  final bool tappable;
}

class _TermState extends State<TermView> {
  int _current = 0;

  get appState {
    return appData.appState;
  }

  @override
  Widget build(BuildContext context) {
    var firstLang = appState.user?.firstLang ?? 'ru';
    var text1 = widget.term.text ?? '';
    var text2 = firstOrElse(
            widget.term.translations
                .where((t) => t.lang == firstLang)
                .map((t) => t.text),
            '') ??
        '';
    var trans = firstByKey(widget.term.transcript, firstLang, true) ?? '';

    // TODO render placeholder if no images
    var slider = widget.term.visual.items.length == 1
        ? makeImage(widget.term.visual.items.first)
        : CarouselSlider(
            //height: 500.0,
            viewportFraction: 1.0,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
            },
            items: widget.term.visual.items.map((t) => makeImage(t)).toList());

    List<Widget> _dots = new List();
    if(widget.term.visual.items.length > 1)
    {
      for (int i = 0; i < widget.term.visual.items.length; i++)
      {
        _dots.add(Container(
          width: 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == i ? Color.fromRGBO(0, 0, 0, 0.9) : Color
                  .fromRGBO(0, 0, 0, 0.6)
          ),
        ));
      }
    }
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
      child: Container(
          constraints: new BoxConstraints.expand(
            height: 200.0,
          ),
          child: Stack(
            // TODO improve position of subtitles
            children: <Widget>[
              new InkWell(
                  onTap: () {
                    if (widget.tappable) {
                      var route = MaterialPageRoute(
                          builder: (_) => new TermDetail(widget.term.uid));
                      Navigator.push(context, route);
                    }
                  },
                  child: slider),
              Positioned(
                left: 10,
                top: 10,
                child: new Text(text1, style: termTextStyle),
              ),
              Positioned(
                left: 10,
                top: 50,
                child: new Text(text2 + ' [' + trans + ']',
                    style: transcriptStyle),
              ),
              Positioned(
                left: 10,
                top: 100,
                child: InkWell(
                    onTap: () {
                      playSound();
                    },
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                            left: 3,
                            top: 1,
                            child: Icon(
                              Icons.play_circle_outline,
                              color: Colors.black,
                              size: 58,
                            )),
                        Positioned(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 60,
                          ),
                        )
                      ],
                    )),
              ),
        Container(
          alignment: Alignment(0, 1),
          child: Row(children: _dots, mainAxisAlignment: MainAxisAlignment.center),
        )
            ],
          )),
    );
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
    if (widget.term.audio.items.isNotEmpty) {
      var sound = widget.term.audio.items.first;
      if (sound != null) {
        audioPlayer.play(sound.url);
      }
    }
  }
}
