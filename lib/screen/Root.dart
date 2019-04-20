import 'package:flutter/material.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/AppState.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/screen/Discover.dart';
import 'package:memoapp/screen/Login.dart';

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
      return DiscoverScreen();
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
