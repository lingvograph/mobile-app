import 'package:flutter/material.dart';
import 'package:memoapp/api.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/appstate.dart';
import 'package:memoapp/model.dart';

// TODO loading state
// TODO login error

class LoginState {
  String username = "";
  String password = "";
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final AppState appState = appData.appState;
  final LoginState data = new LoginState();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  void submit() async {
    final form = _formKey.currentState;
    if (!form.validate()) {
      return;
    }
    // setState(() => _isLoading = true);
    form.save();

    // TODO handle login error
    var token = await login(data.username, data.password);
    // TODO request user data/preferences
    var user = User(data.username, 'ru');

    appState.user = user;
    appState.apiToken = token;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  String validateUsername(String value) {
    // TODO validate username or email
//    try {
//      Validate.isEmail(value);
//    } catch (e) {
//      return 'The E-mail Address must be a valid email address.';
//    }
    return null;
  }

  String validatePassword(String value) {
    if (value.length < 6) {
      return 'The Password must be at least 6 characters.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        padding: new EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // username field
              TextFormField(
                onSaved: (String value) {
                  data.username = value;
                },
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  labelText: 'Username or email address',
                ),
                validator: validateUsername,
              ),
              // password field
              TextFormField(
                onSaved: (String value) {
                  data.password = value;
                },
                obscureText: true, // password
                decoration: InputDecoration(
                  hintText: 'Password',
                  labelText: 'Enter your password',
                ),
                validator: validatePassword,
              ),
              // login button
              Container(
                  width: screenSize.width,
                  margin: new EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    onPressed: submit,
                    child: Text(
                      'Login',
                      style: new TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
