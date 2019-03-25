import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/*Widget used to decorate input fields with rounded and fill it with grey color*/
class RecordAudioWidget extends StatefulWidget {
  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<RecordAudioWidget> {
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
      String result = await flutterSound.stopRecorder();
      print('stopRecorder: $result');

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
    String path = await flutterSound.startPlayer(null);
    await flutterSound.setVolume(1.0);
    print('startPlayer: $path');

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

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20),
          child: Container(
            alignment: Alignment(0, 0),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              "Content Managment",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: Text(
                this._recorderTxt,
                style: TextStyle(
                  fontSize: 28.0,
                  color: Colors.black,
                ),
              ),
            ),
            _isRecording
                ? LinearProgressIndicator(
                    value: 100.0 / 120.0 * (this._dbLevel ?? 1) / 100,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    backgroundColor: Colors.red,
                  )
                : Container()
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              alignment: Alignment(0, 0),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                "Record",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
              width: 56.0,
              height: 56.0,
              child: ClipOval(
                child: FlatButton(
                    onPressed: () {
                      if (!this._isRecording) {
                        return this.startRecorder();
                      }
                      this.stopRecorder();
                    },
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                        this._isRecording
                            ? Icons.keyboard_voice
                            : Icons.keyboard_voice,
                        color: this._isRecording ? Colors.red : Colors.blue)),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
        Column(
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
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Container(
            alignment: Alignment(0, 0),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: <Widget>[
                Container(
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
                ),
                Container(
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
                ),
                Container(
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
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
          ),
        ),
        Container(
            height: 56.0,
            child: Slider(
                value: slider_current_position,
                min: 0.0,
                max: max_duration,
                onChanged: (double value) async {
                  await flutterSound.seekToPlayer(value.toInt());
                },
                divisions: max_duration.toInt()))
      ],
    );
  }
}
