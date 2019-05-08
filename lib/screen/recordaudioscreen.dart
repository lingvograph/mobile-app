import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memoapp/api/model.dart';
import 'package:memoapp/components/InputFieldDecoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/api/api.dart';
import 'package:uuid/uuid.dart';

class RecordAudioScreen extends StatefulWidget {
  TermInfo term;
  RecordAudioScreen({this.term});
  @override
  _RecordAudioScreen createState() => _RecordAudioScreen();
}

class _RecordAudioScreen extends State<RecordAudioScreen> {
  bool _isRecording = false;
  bool _isPlaying = false;
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  FlutterSound flutterSound;

  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';
  double _dbLevel;

  double slider_current_position = 0.0;
  double max_duration = 1.0;
  String path;
  String way;
  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
  }

  void startRecorder() async {
    try {
      String path = await flutterSound.startRecorder(null);
      way = path;
      /*
      /storage/emulated/0/default.mp4 вот такой путь у записи
      */
      print('startRecorder: $path');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

        this.setState(() {
          this._recorderTxt = txt.substring(0, 8);
        });
      });
      _dbPeakSubscription =
          flutterSound.onRecorderDbPeakChanged.listen((value) {
        print("got update -> $value");
        setState(() {
          this._dbLevel = value;
        });
      });

      this.setState(() {
        this._isRecording = true;
      });
    } catch (err) {
      print('startRecorder error: $err');
    }
  }

  void stopRecorder() async {
    try {
      path = await flutterSound.stopRecorder();
      print('stopRecorder: $path');

      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
      if (_dbPeakSubscription != null) {
        _dbPeakSubscription.cancel();
        _dbPeakSubscription = null;
      }

      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  void startPlayer() async {
    _recorderTxt = '00:00:00';
    _playerTxt = '00:00:00';
    String path = await flutterSound.startPlayer(null);

    await flutterSound.setVolume(1.0);

    // TODO upload should be initiated by save button
    //uploadAudio(path);

    try {
      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          slider_current_position = e.currentPosition;
          max_duration = e.duration;

          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt(),
              isUtc: true);
          String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
          this.setState(() {
            this._isPlaying = true;
            this._playerTxt = txt.substring(0, 8);
          });
        }
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void stopPlayer() async {
    try {
      String result = await flutterSound.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }

      this.setState(() {
        this._isPlaying = false;
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void pausePlayer() async {
    String result = await flutterSound.pausePlayer();
    print('pausePlayer: $result');
  }

  void resumePlayer() async {
    String result = await flutterSound.resumePlayer();
    print('resumePlayer: $result');
  }

  void seekToPlayer(int milliSecs) async {
    int secs = Platform.isIOS ? milliSecs / 1000 : milliSecs;

    String result = await flutterSound.seekToPlayer(secs);
    print('seekToPlayer: $result');
  }

  void uploadAudio(String path) async{
    print('uploadFile: $path');
    File f = new File(path);

    List<int> bytes = f.readAsBytesSync();

    var uuid = new Uuid();
    final user = appData.appState.user;
    String dataUid = uuid.v4();
    final remotePath = "user/${user.uid}/audio/${dataUid}.mp3";

    var res = await upload("$remotePath", 'aduio/mpeg', bytes);
    TermUpdate tup = new TermUpdate();
    tup.audioUid = res.uid;
    print(tup.imageUid);
    var res2 = await upadteTerm(widget.term.uid, tup);
    print(res2.toString());
  }

  @override
  Widget build(BuildContext context) {
    var audioRecordName = Padding(
      padding: EdgeInsets.all(30),
      child: Container(
        child: new Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                boxShadow: <BoxShadow>[
                  BoxShadow(color: Colors.black, blurRadius: 5)
                ],
                borderRadius: BorderRadius.circular(20)),
            width: 300,
            child: new TextField(style: new TextStyle(color: Colors.black))),
      ),
    );
    var recordText = Container(
      alignment: Alignment(0, 0),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.grey[500], blurRadius: 5)
          ]),
      child: Text(
        "Record",
        style: TextStyle(fontSize: 20),
      ),
    );
    var recordDuration = Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  this._recorderTxt,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                ),
              );
    var recordAudioBtn = Container(
      width: 100.0,
      height: 80.0,
      child: ClipOval(
        child: FlatButton(
          onPressed: () {
            if (!this._isRecording) {
              return this.startRecorder();
            }
            this.stopRecorder();
          },
          padding: EdgeInsets.all(8.0),
          child: Container(
              child: Column(
            children: <Widget>[
              AnimatedCrossFade(
                  firstChild: Icon(
                    FontAwesomeIcons.microphone,
                    color: Colors.blue,
                  ),
                  secondChild: Icon(
                    FontAwesomeIcons.microphoneSlash,
                    color: Colors.red,
                  ),
                  crossFadeState: _isRecording
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: Duration(milliseconds: 500)),
              recordDuration
            ],
          )),
        ),
      ),
    );
    var playProgressBar = Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 60.0, bottom: 16.0),
                child: Text(
                  this._playerTxt,
                  style: TextStyle(
                    fontSize: 28.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          );
    var playBtn = Container(
                    width: 56.0,
                    height: 56.0,
                    child: ClipOval(
                      child: FlatButton(
                        onPressed: () {
                          startPlayer();
                        },
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 30,
                        ),
                      ),
                    ),
                  );
    var pauseBtn = Container(
                    width: 56.0,
                    height: 56.0,
                    child: ClipOval(
                      child: FlatButton(
                        onPressed: () {
                          pausePlayer();
                        },
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.pause_circle_outline,
                          size: 40,
                        ),
                      ),
                    ),
                  );
    var stopBtn = Container(
                    width: 56.0,
                    height: 56.0,
                    child: ClipOval(
                      child: FlatButton(
                        onPressed: () {
                          stopPlayer();
                        },
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.stop,
                          size: 30,
                        ),
                      ),
                    ),
                  );
    var playDuration = Container(
                      height: 56.0,
                      child: Slider(
                          value: slider_current_position,
                          min: 0.0,
                          max: max_duration,
                          onChanged: (double value) async {
                            await flutterSound.seekToPlayer(value.toInt());
                          },
                          divisions: max_duration.toInt()));
    var sendRecordBtn = Stack(
            alignment: Alignment(-0.8, 0),
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: Colors.grey[500], blurRadius: 5)
                    ]),
                padding: EdgeInsets.only(top: 10),
                alignment: Alignment(-0.8, 0),
              ),
              Positioned(
                top: 10,
                left: 45,
                child: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.upload,
                    color: Colors.blue,
                    size: 40,
                  ),
                  onPressed: () {
                    uploadAudio(way);
                  },
                ),
              )
            ],
          );
    return Scaffold(
      appBar: AppBar(
        title: new Row(
          children: <Widget>[
            Icon(FontAwesomeIcons.microphoneAlt),
            Text(" Your recording studio")
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
          ),
          //audioRecordName,
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Row(
            children: <Widget>[
              recordText,
              recordAudioBtn,
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          playProgressBar,
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Container(
              alignment: Alignment(0, 0),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: Colors.grey[500], blurRadius: 5)
                  ],
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: <Widget>[
                  playBtn,
                  pauseBtn,
                  stopBtn,
                  playDuration
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          sendRecordBtn
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
