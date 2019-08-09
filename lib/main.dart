import 'package:flutter/material.dart';
import 'package:memoapp/AppState.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/routes.dart';

void main() async {
  var state = new AppState(); // await AppState.load();
  // TODO check API token
  appData.appState = state;
  return runApp(App(state));
}

class App extends StatelessWidget {
  final AppState state;

  App(this.state);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memoapp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: routes,
    );
  }
}
