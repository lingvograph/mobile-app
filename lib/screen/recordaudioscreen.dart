import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RecordAudioScreen extends StatefulWidget {

  @override
  _RecordAudioScreen createState() => _RecordAudioScreen();
}

class _RecordAudioScreen extends State<RecordAudioScreen> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Icon(FontAwesomeIcons.palette),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Color picker',
            ),


          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}