import 'package:flutter/material.dart';
import 'package:memoapp/api.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/screen/home.dart';
import 'package:memoapp/screen/login.dart';
import 'package:memoapp/appstate.dart';

class RootScreen extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<RootScreen> implements AuthStateListener {
  final AppState state = appData.appState;

  _RootState() {
    authState.subscribe(this);
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoggedIn) {
      return HomeScreen();
    }
    return LoginScreen();
  }

  // TODO global handling of unauthorized error
  @override
  void onChanged(bool isLoggedIn) {
    var route = isLoggedIn ? '/home' : '/login';
    Navigator.of(context).pushReplacementNamed(route);
  }
}
