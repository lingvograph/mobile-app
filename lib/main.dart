import 'package:flutter/material.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/screen/home.dart';
import 'package:memoapp/screen/login.dart';
import 'package:memoapp/state.dart';

void main() async {
  var state = await AppState.load();
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
      home: AppBody(state),
    );
  }
}

class AppBody extends StatefulWidget {
  final AppState state;

  AppBody(this.state);

  @override
  _AppState createState() => _AppState(state);
}

class _AppState extends State<AppBody> {
  AppState state;
  LoginState _loginState = new LoginState();

  _AppState(this.state);

  void onLogin(LoginData data) {
    setState(() {
      state.user = data.user;
      state.apiToken = data.apiToken;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(state)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoggedIn) {
      return HomeScreen(state);
    }
    return LoginScreen(
        state: _loginState,
        onLogin: onLogin,
    );
  }
}
