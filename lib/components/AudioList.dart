import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:memoapp/api.dart';

// TODO make it scrollable

/*Widget used to decorate input fields with rounded and fill it with grey color*/
class AudioList extends StatefulWidget {
  TermInfo term;

  //предполагаю из него будем вытаскивать озвучки по ID
  AudioList({@required this.term});

  @override
  _AudioListState createState() => _AudioListState(term);
}

class _AudioListState extends State<AudioList> {
  TermInfo term;

  _AudioListState(this.term);

  List<Widget> audios;

  @override
  Widget build(BuildContext context) {
    var audios = term.audio.items.map((t) => new LoadedAudio(t)).toList();

    return new Center(
      child: Padding(
        padding: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
        child: Container(
          padding: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
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

  LoadedAudio(this.audio);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.only(top: 4, left: 20, right: 20),
      child: Container(
          decoration: BoxDecoration(
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
                        ),
                        Text(
                          "good",
                          style: TextStyle(fontSize: 13),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.thumb_down,
                            size: 15,
                          ),
                        ),
                        Text(
                          "bad",
                          style: TextStyle(fontSize: 13),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.favorite,
                            size: 15,
                          ),
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
