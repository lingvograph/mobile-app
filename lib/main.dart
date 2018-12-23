import 'package:flutter/material.dart';
import 'package:memoapp/home.dart';
import 'package:memoapp/login.dart';
import 'package:memoapp/model.dart';
import 'package:memoapp/state.dart';

void main() async {
  var state = await AppState.load();
  return runApp(App(state));
}

class App extends StatelessWidget {
  AppState state;

  App(this.state);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lingvo Graph App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AppBody(state),
    );
  }
}

class AppBody extends StatefulWidget {
  AppState state;

  AppBody(this.state);

  @override
  _AppState createState() => _AppState(state);
}

class _AppState extends State<AppBody> {
  AppState state;
  LoginData _loginState = new LoginData();

  _AppState(this.state);

  void onLogin(User user) {
    state.user = user;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(state)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoggedIn) {
      return HomePage(state);
    }
    return LoginPage(
        data: _loginState,
        onLogin: onLogin,
    );
  }
}
