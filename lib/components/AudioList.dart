import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/api/model.dart';

// TODO make it scrollable

class AudioList extends StatefulWidget {
  TermInfo term;
  VoidCallback refresh;

  AudioList(this.term, this.refresh);

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
    var audios =
        term.audio.items.map((t) => new LoadedAudio(t, refresh)).toList();

    return new Center(
      child: Padding(
        padding: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
        child: Container(
          padding: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey[300], blurRadius: 4)],
              color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
          child: new Column(
            children: <Widget>[
              new Column(
                children: audios,
              ),
              Padding(
                padding: EdgeInsets.all(10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadedAudio extends StatelessWidget {
  MediaInfo audio;
  VoidCallback refresh;

  LoadedAudio(this.audio, this.refresh);

  get appState {
    return appData.appState;
  }

  @override
  Widget build(BuildContext context) {
    var userId = appState.user.uid;
    return Padding(
      padding: EdgeInsets.only(top: 4, left: 20, right: 20),
      child: Container(
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey[500], blurRadius: 4)],
              color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.only(left: 2, right: 10),
            child: Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.play_arrow,
                      size: 25,
                    ),
                    onPressed: playSound),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                    new Row(
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
                          " (${audio.author.gender}, ${audio.author.country})",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        )
                      ],
                    ),
                    new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "7 votes",
                          style: TextStyle(fontSize: 13),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.thumb_up,
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
                        ),
                        Text(
                          audio.likes.toString(),
                          style: TextStyle(fontSize: 13),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.thumb_down,
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
                        ),
                        Text(
                          audio.dislikes.toString(),
                          style: TextStyle(fontSize: 13),
                        ),
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
