import 'package:flutter/material.dart';
import 'package:memoapp/home.dart';
import 'package:memoapp/login.dart';
import 'package:memoapp/model.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lingvo Graph App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AppBody(),
    );
  }
}

class AppBody extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<AppBody> {
  User _user;
  LoginData _loginState = new LoginData();

  void onLogin(User user) {
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user != null) {
      return HomePage();
    }
    return LoginPage(
        data: _loginState,
        onLogin: onLogin,
    );
  }
}
