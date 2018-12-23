import 'package:flutter/material.dart';
import 'package:memoapp/state.dart';

class HomePage extends StatelessWidget {
  AppState state;

  HomePage(this.state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Hello, ${state.user.name}"),
    );
  }
}
