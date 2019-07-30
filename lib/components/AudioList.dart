import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/api/model.dart';
import 'package:country_icons/country_icons.dart';
import 'package:flutter/rendering.dart';

// TODO make it scrollable

class AudioList extends StatefulWidget {
  TermInfo term;
  VoidCallback refresh;

  AudioList(this.term);

  @override
  _AudioListState createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {


  TermInfo get term {
    return widget.term;
  }

  VoidCallback get refresh {
    return widget.refresh;
  }

  @override
  Widget build(BuildContext context) {
    var audios = term.audio.items
        .map((t) => new LoadedAudio(t, refresh, term.lang))
        .toList();

    return new Center(
      child: Padding(
        padding: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
        child: Container(
          padding: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey[400], blurRadius: 10, offset: Offset(0, 0))
          ], color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
          child: new Column(
            children: <Widget>[
              new Column(
                children: audios,
              ),

              Padding(
                padding: EdgeInsets.all(10),
              ),
            ],
          ), //
        ),
      ),
    );
  }
}

class MyObservableWidget extends StatefulWidget {
  const MyObservableWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new MyObservableWidgetState();
}

class MyObservableWidgetState extends State<MyObservableWidget> {
  @override
  Widget build(BuildContext context) {
    return new Container(height: 1.0, color: Colors.transparent);
  }
}

class ContainerWithBorder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration:
          new BoxDecoration(border: new Border.all(), color: Colors.grey),
    );
  }
}

class LoadedAudio extends StatelessWidget {
  MediaInfo audio;
  VoidCallback refresh;
  String lang;

  LoadedAudio(this.audio, this.refresh, this.lang);

  get appState {
    return appData.appState;
  }

  @override
  Widget build(BuildContext context) {
    var userId = appState.user.uid;
    var playBtn = IconButton(
        icon: Icon(
          Icons.play_arrow,
          size: 25,
        ),
        onPressed: playSound);
    var dislikes = Text(
      audio.dislikes.toString(),
      style: TextStyle(fontSize: 13),
    );
    var dislikeBtn = IconButton(
      icon: Icon(
        FontAwesomeIcons.thumbsDown,
        size: 15,
      ),
      onPressed: () async {
        try {
          await dislike(userId, audio.uid);
          refresh();
        } catch (err) {
          // TODO display error snackbar
        }
      },
    );
    var likeBtn = IconButton(
      icon: Icon(
        FontAwesomeIcons.thumbsUp,
        size: 15,
      ),
      onPressed: () async {
        try {
          await like(userId, audio.uid);
          refresh();
        } catch (err) {
          // TODO display error snackbar
        }
      },
    );
    var spellerInfo = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Spelled user "),
        Text(
          audio.author.name,
          style: TextStyle(color: Colors.blueAccent),
        ),
        // TODO consider display icons
        Text(
          " (${audio.author.gender.length > 0 ? audio.author.gender : "Alien"}, ${audio.author.country.length > 0 ? audio.author.country : "Mars"})",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        Padding(
          padding: EdgeInsets.all(2),
        ),
        Text(
          audio.author.firstLang == lang ? "native" : "native",
          style: TextStyle(
              color: audio.author.firstLang == lang
                  ? Colors.blueAccent
                  : Colors.grey[600],
              decoration: audio.author.firstLang == lang
                  ? TextDecoration.none
                  : TextDecoration.lineThrough),
        ),
      ],
    );
    var likes = Text(
      (audio.likes + audio.dislikes).toString() + " votes",
      style: TextStyle(fontSize: 13),
    );
    return Padding(
      padding: EdgeInsets.only(top: 8, left: 20, right: 20),
      child: Container(
          decoration: BoxDecoration(boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.grey[500], blurRadius: 4)
          ], color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.only(left: 2, right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                playBtn,
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                    spellerInfo,
                    new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        likes,
                        likeBtn,
                        Text(
                          audio.likes.toString(),
                          style: TextStyle(fontSize: 13),
                        ),
                        dislikeBtn,
                        dislikes,
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  void playSound() {
    var audioPlayer = new AudioPlayer();
    if (audio != null) {
      audioPlayer.play(audio.url);
    }
  }
}
