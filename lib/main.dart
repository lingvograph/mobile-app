import 'package:flutter/material.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/routes.dart';
import 'package:memoapp/appstate.dart';

void main() async {
  var state = await AppState.load();
  // TODO check API token
  appData.appState = state;
  appData.lingvo.nextWord();
  return runApp(App(state));
}

class App extends StatelessWidget {
  final AppState state;

  App(this.state);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lingvo Graph App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: routes,
    );
  }
}
